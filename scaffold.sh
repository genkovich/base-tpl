#!/usr/bin/env bash
# scaffold.sh — субтрактивний скафолд нового проєкту з base-tpl.
#
# Використання:
#   scaffold.sh <target-dir> <slug> [owner] [опції]
#
#   <target-dir>  тека нового проєкту (може існувати; допустимий вміст —
#                 лише docs/ з idea-brief.md)
#   <slug>        kebab-case назва проєкту (task-tracker)
#   [owner]       GitHub-owner для module path і GHCR-образів (default: example)
#
# Опції (субтракція батарейок):
#   --no-web            без фронтенда (тека web/ + сервіси + CI-джоби)
#   --no-deploy         без деплою (deploy-конфіги + deploy.yml)
#   --no-ci             без CI (ci.yml)
#   --no-observability  без Prometheus/Grafana (ендпоінт /metrics в api лишається)
#   --display <назва>   людська назва проєкту (default: slug у Title Case)
#   --brief <шлях>      покласти idea-brief у docs/idea-brief.md нового репо
#   --no-git            не робити git init (надрукує команди для ручного запуску)
#
# Повний вибір (без --no-*) відтворює темплейт байт-у-байт (модуло rename).
# Блоки у спільних файлах вирізаються за маркерами:
#   YAML/Makefile/Caddyfile:  # battery:<name> ... # /battery:<name>
#   Markdown:                 <!-- battery:<name> --> ... <!-- /battery:<name> -->
set -euo pipefail

die() { echo "scaffold.sh: $*" >&2; exit 1; }

[ $# -ge 2 ] || { grep '^#' "$0" | sed -n '2,24p' | sed 's/^# \{0,1\}//'; exit 1; }

TARGET=$1; SLUG=$2; shift 2
OWNER="example"
if [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; then OWNER=$1; shift; fi

NO_WEB=0 NO_DEPLOY=0 NO_CI=0 NO_OBS=0 BRIEF="" NO_GIT=0 DISPLAY=
while [ $# -gt 0 ]; do
  case "$1" in
    --no-web) NO_WEB=1 ;;
    --no-deploy) NO_DEPLOY=1 ;;
    --no-ci) NO_CI=1 ;;
    --no-observability) NO_OBS=1 ;;
    --display) shift; DISPLAY=${1:?"--display потребує назву"} ;;
    --brief) shift; BRIEF=${1:?"--brief потребує шлях"} ;;
    --no-git) NO_GIT=1 ;;
    *) die "невідома опція: $1" ;;
  esac
  shift
done

echo "$SLUG" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || die "slug має бути kebab-case: $SLUG"
echo "$OWNER" | grep -Eq '^[A-Za-z0-9-]+$' || die "owner виглядає невалідним: $OWNER"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TPL="$SCRIPT_DIR/templates/go-react"
[ -d "$TPL" ] || die "не знайдено templates/go-react поруч зі скриптом"

# GNU vs BSD sed
if sed --version >/dev/null 2>&1; then SED_I=(sed -i); else SED_I=(sed -i ''); fi

# --- Target: нова або майже порожня тека (дозволяємо docs/ від interview)
mkdir -p "$TARGET"
TARGET=$(cd "$TARGET" && pwd)
leftover=$(find "$TARGET" -mindepth 1 -maxdepth 1 -not -name docs -not -name '.DS_Store' | head -1)
[ -z "$leftover" ] || die "цільова тека не порожня: $leftover"

# --- Копія: tracked-файли темплейта (git archive), fallback tar для не-git копій
if git -C "$SCRIPT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
  git -C "$SCRIPT_DIR" archive HEAD:templates/go-react | tar -x -C "$TARGET"
else
  (cd "$TPL" && tar -c --exclude node_modules --exclude .DS_Store .) | tar -x -C "$TARGET"
fi

cd "$TARGET"

# --- Субтракція: awk вирізає марковані блоки, rm — цілі теки/файли
cut_battery() {
  b=$1
  grep -rIl "battery:$b" . 2>/dev/null | while read -r f; do
    awk -v b="$b" '
      index($0, "/battery:" b) > 0 { skip = 0; next }
      index($0, "battery:" b) > 0  { skip = 1; next }
      !skip
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done
}

CUT_SUMMARY=""
if [ "$NO_WEB" = 1 ]; then
  rm -rf web
  cut_battery web
  # deploy.yml: джоба build-web вирізана маркером, лишається залежність
  if [ -f .github/workflows/deploy.yml ]; then
    "${SED_I[@]}" -e 's/needs: \[build-api, build-web\]/needs: [build-api]/' .github/workflows/deploy.yml
  fi
  CUT_SUMMARY="$CUT_SUMMARY web"
fi
if [ "$NO_DEPLOY" = 1 ]; then
  rm -f .github/workflows/deploy.yml deploy/Caddyfile deploy/docker-compose.prod.yml deploy/env.prod.example
  cut_battery deploy
  CUT_SUMMARY="$CUT_SUMMARY deploy"
fi
if [ "$NO_CI" = 1 ]; then
  rm -f .github/workflows/ci.yml
  cut_battery ci
  CUT_SUMMARY="$CUT_SUMMARY ci"
fi
if [ "$NO_OBS" = 1 ]; then
  rm -rf deploy/prometheus deploy/grafana
  cut_battery observability
  CUT_SUMMARY="$CUT_SUMMARY observability"
fi
rmdir deploy .github/workflows .github 2>/dev/null || true

# --- Rename: example/myapp -> owner/slug (перший — довший патерн), myapp -> slug, MyApp -> Display
if [ -z "$DISPLAY" ]; then
  DISPLAY=$(echo "$SLUG" | awk -F- '{ for (i=1; i<=NF; i++) $i = toupper(substr($i,1,1)) substr($i,2) } 1' OFS=' ')
fi
grep -rIl -e 'myapp' -e 'MyApp' . 2>/dev/null | while read -r f; do
  LC_ALL=C "${SED_I[@]}" \
    -e "s|example/myapp|$OWNER/$SLUG|g" \
    -e "s|myapp|$SLUG|g" \
    -e "s|MyApp|$DISPLAY|g" "$f"
done
if [ -f deploy/grafana/dashboards/myapp.json ]; then
  mv deploy/grafana/dashboards/myapp.json "deploy/grafana/dashboards/$SLUG.json"
fi

# --- Env для make up
cp api/.env.docker.example api/.env.docker

# --- Idea-brief від /sdlc-interview
if [ -n "$BRIEF" ]; then
  [ -f "$BRIEF" ] || die "brief не знайдено: $BRIEF"
  mkdir -p docs
  if [ "$(cd "$(dirname "$BRIEF")" && pwd)/$(basename "$BRIEF")" != "$TARGET/docs/idea-brief.md" ]; then
    cp "$BRIEF" docs/idea-brief.md
  fi
fi

# --- Git init + t0
if [ "$NO_GIT" = 1 ]; then
  echo "git init пропущено (--no-git). Заверши вручну:"
  echo "  cd $TARGET && git init -b main && git add -A && git commit -m 't0: scaffold $SLUG from base-tpl (go-react)'"
else
  git init -b main -q
  git add -A
  git commit -q -m "t0: scaffold $SLUG from base-tpl (go-react)"
fi

echo ""
echo "Готово: $TARGET (slug=$SLUG, owner=$OWNER)"
[ -n "$CUT_SUMMARY" ] && echo "Вирізано батарейки:$CUT_SUMMARY"
echo "Далі:"
echo "  /init        — згенерувати кореневий CLAUDE.md (навмисно відсутній у темплейті)"
echo "  make check   — наскрізна перевірка"
echo "  make up      — повний локальний стек"
echo "  Google-логін потребує реальних GOOGLE_CLIENT_ID/SECRET у api/.env.docker"
