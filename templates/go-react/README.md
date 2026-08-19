# MyApp — full-stack темплейт (Go + React)

Базовий темплейт застосунку: модульний Go-моноліт + React SPA + повна
інфраструктура. Продуктових фіч немає навмисно — це стартова точка, з якої
фічі наростають (напр., через SDD-пайплайн). Головна сторінка — гола кнопка
Google-логіну, дашборд — голе «Hello»: дизайн будується у твоєму проєкті.

- **api/** — Go: chi + pgx + golang-migrate, Google OAuth + JWT, `/livez` `/readyz`
  `/metrics`, testcontainers-інтеграційні тести. Чартер: `api/CLAUDE.md`.
- **web/** — React Router 7 SPA (ssr:false): Tailwind 4 + shadcn-примітиви, FSD,
  Google-логін, vitest + Playwright.
- **docker-compose.yml** — повний локальний стек: Postgres + міграції + API + web +
  Prometheus + Grafana (`make up`).
- **.github/workflows/** — CI (vet/lint/unit/integration + web) і деплой
  (GHCR-образи → VPS → міграції → health-гейт).
- **deploy/** — прод-стек: Caddy (авто-TLS), Prometheus, Grafana.
- **.claude/** — harness: path-rules для Go, gofmt-хук, go-скіли, агенти-ревʼюери.
  Кореневого CLAUDE.md немає навмисно — згенеруй його `/init` у своєму проєкті.

## Швидкий старт

```bash
cp api/.env.docker.example api/.env.docker   # dummy-значення; Google-логін потребує реальних CLIENT_ID/SECRET
make up                                      # повний стек
open http://localhost:5173                   # web
open http://localhost:3000                   # Grafana
make check                                   # vet + lint + tests (api) · typecheck + vitest (web)
```

Дев-цикл без docker для api/web: `make -C api run` + `cd web && npm run dev`
(Postgres лишається з compose).
