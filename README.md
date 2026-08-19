# base-tpl

Темплейт-фабрика повних застосунків. Один наповнений шлях — **`templates/go-react`**:
модульний Go-моноліт (chi + pgx + golang-migrate, Google OAuth + JWT, testcontainers)
+ React Router 7 SPA (Tailwind 4, shadcn, FSD) + docker-compose стек + CI + деплой на
VPS (GHCR → Caddy авто-TLS) + Prometheus/Grafana. Деталі — у README темплейта.

## Скафолд нового проєкту

**Рекомендований шлях** — скіл [`/sdlc-scaffold`](https://github.com/genkovich/sdlc)
для Claude Code: інтерв'ю про стек і батарейки, потім виклик двигуна:

```bash
claude plugin marketplace add genkovich/sdlc
claude plugin install sdlc@sdlc
# у порожній теці:  /sdlc-interview  →  /sdlc-scaffold
```

**Без Claude Code** — двигун напряму:

```bash
git clone --depth 1 https://github.com/genkovich/base-tpl
base-tpl/scaffold.sh ./my-app my-app my-github-user
```

## Батарейки (субтракція)

`scaffold.sh` копіює повний темплейт і **фізично видаляє** невибране — теки, сервіси
compose, CI-джоби, рядки README. Без прапорів результат — темплейт байт-у-байт.

| Прапор | Що зникає |
|---|---|
| `--no-web` | `web/`, сервіс web у compose/prod, web-джоби CI, VITE-аргументи deploy |
| `--no-deploy` | `deploy/` конфіги (Caddy, prod-compose), `deploy.yml` |
| `--no-ci` | `ci.yml` |
| `--no-observability` | Prometheus + Grafana локально і в проді (`/metrics` в api лишається) |

Інші опції: `--display <назва>`, `--brief <шлях до idea-brief.md>`, `--no-git`.

Блоки у спільних файлах розмічені маркерами `# battery:<name> … # /battery:<name>`
(`<!-- battery:<name> -->` у Markdown). CI цього репо скафолдить три профілі
(full / api-only / lean) на кожен пуш — дрейф маркерів ловиться одразу.

## Структура

```
scaffold.sh           # двигун: копія → субтракція → rename → git init
templates/go-react/   # наповнений шлях (нейтральний бренд myapp/MyApp)
.github/workflows/    # CI-матриця профілів
```
