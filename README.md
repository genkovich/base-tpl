# base-tpl

Репозиторій базових темплейтів для скафолдингу нових проєктів скілом
[`skills/scaffold-project`](skills/scaffold-project/SKILL.md).

## Структура

- `templates/go-react/` — наповнений шлях: Go (chi/pgx/golang-migrate, модульний
  моноліт) + React Router 7 SPA (Tailwind 4, shadcn, FSD) + повна інфра
  (compose-стек із Grafana, CI, deploy на VPS, `.claude/`-harness).
  Нейтральний бренд `myapp`; кореневого CLAUDE.md немає навмисно — його
  генерує `/init` у скафолднутому проєкті.
- `skills/scaffold-project/` — скіл-скафолдер: інтерв'ю виборів → копія →
  rename → `git init`. Інші шляхи (PHP/Python/TS, мікросервіси, flat/без
  фронта) поки не наповнені — скіл чесно про це каже.

## Інсталяція скіла

```bash
rm -rf ~/.claude/skills/scaffold-project
cp -R skills/scaffold-project ~/.claude/skills/scaffold-project
```

Джерело правди — цей репозиторій; після правок скіла перекопіюй.

## Інваріант

`templates/go-react` сам по собі зелений: `make check` усередині темплейта
проходить на чистому clone (це ганяє CI). Скіл копіює **tracked**-файли
(`git archive HEAD`) — некомічені зміни в темплейт не потрапляють.
