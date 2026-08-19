---
name: scaffold-project
description: Use when starting a new full-stack project from the local base-tpl — the user says "/scaffold-project", "заскафолдь проєкт", "новий проєкт з темплейта", "scaffold a new app", or wants a Go+React starter with auth, CI/CD, and deploy already wired.
---

# Scaffold Project

## Overview

Створює новий проєкт фізичною копією наповненого шляху з `~/sources/base-tpl/templates/`,
перейменовує нейтральний бренд (`myapp`/`MyApp`) на назву проєкту і робить `git init` + t0-коміт.
Джерело копії — tracked-файли base-tpl (`git archive`), не робоча копія.

## Кроки

### 1. Інтерв'ю

Якщо скіл викликано з аргументом — це slug проєкту, назву не питай.

1. **Назва** (якщо нема аргументу): спитай kebab-case slug (напр. `task-tracker`).
   Шлях за замовчуванням: `./<slug>` від поточної теки; інший шлях — якщо користувач дав.
2. **Стек** — один виклик AskUserQuestion із трьома питаннями, рекомендоване першим:
   - Мова бекенда: **Go (Recommended)** / PHP / Python / TypeScript
   - Архітектура: **Модульний моноліт (Recommended)** / Мікросервіси
   - Фронтенд: **React + FSD (Recommended)** / Flat React / Без фронта

**Чесність про наповнення:** у base-tpl наповнений рівно один шлях —
`templates/go-react` (Go + модульний моноліт + React FSD). Будь-який інший вибір →
зупинись і скажи прямо: «цей шлях у base-tpl ще не наповнено — наповни
`templates/<стек>` або обери дефолтний». Не генеруй заглушок замість темплейта.

### 2. Батарейки (інформативно, без питання)

Після вибору шляху скажи одним абзацом, що в go-react уже вшито: Google OAuth + JWT,
health-ендпоінти `/livez` `/readyz`, Prometheus `/metrics` + Grafana-дашборд,
testcontainers-інтеграційні тести, CI (vet/lint/test/integration + web), deploy-workflow
(GHCR → VPS з health-гейтом), Caddy з авто-TLS.

### 3. Копія

```bash
BASE_TPL="$HOME/sources/base-tpl"
mkdir -p "$TARGET"
git -C "$BASE_TPL" archive HEAD:templates/go-react | tar -x -C "$TARGET"
```

`git archive` дає тільки tracked-файли — жодних node_modules чи артефактів робочої копії.

### 4. Перейменування

- `OWNER`: `gh api user -q .login` якщо `gh` авторизований, інакше `example`.
- `DISPLAY`: slug у Title Case (`task-tracker` → `Task Tracker`).

```bash
cd "$TARGET"
grep -rIl -e 'myapp' -e 'MyApp' . | while read -r f; do
  LC_ALL=C sed -i '' \
    -e "s|example/myapp|$OWNER/$SLUG|g" \
    -e "s|myapp|$SLUG|g" \
    -e "s|MyApp|$DISPLAY|g" "$f"
done
mv deploy/grafana/dashboards/myapp.json "deploy/grafana/dashboards/$SLUG.json"
```

Порядок виразів важливий: довший `example/myapp` (module path і GHCR-образи) — перший.
`grep -rIl` пропускає бінарні файли. На Linux — `sed -i` без `''`.
Wordmark `my.app` у `web/src/shared/ui/Wordmark.tsx` навмисно НЕ чіпай —
бренд і дизайн робляться окремою дизайн-лінією в проєкті.

### 5. Env + git init

```bash
cp api/.env.docker.example api/.env.docker
git init -b main && git add -A
git commit -m "t0: scaffold $SLUG from base-tpl (go-react)"
```

### 6. Фінальне повідомлення користувачу

- Запусти **`/init`** — кореневого CLAUDE.md у темплейті навмисно немає,
  його генерує `/init` уже з назвою і контекстом проєкту (`api/CLAUDE.md`
  і path-rules `.claude/rules/go-*.md` приїхали з темплейтом і вже працюють).
- `make check` — vet + lint + tests (api), typecheck + vitest (web).
- `make up` → http://localhost:5173 (повний стек із Grafana на :3000).
- Google-логін потребує реальних `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET`
  у `api/.env.docker` (dummy-значення дають живий стек без логіну).

## Поширені помилки

- `cp -R` робочої копії замість `git archive` → у скафолд затікають node_modules.
- Зміни в base-tpl не закомічені → `git archive HEAD` їх не бачить; закоміть спершу.
- Пропущений rename `myapp.json` → неконсистентна назва дашборда Grafana.
- sed без урахування порядку → `example/myapp` розірветься заміною `myapp`.
