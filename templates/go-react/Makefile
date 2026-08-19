.PHONY: up down logs check api-check web-check doctor preflight seed

# --- Повний локальний стек (proof-of-life) ---

up:
	docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

# --- Наскрізна перевірка (критерій t0: чистий clone → make check зелений) ---

check: api-check web-check

api-check:
	$(MAKE) -C api check

web-check:
	cd web && (test -d node_modules || npm ci) && npm run typecheck && npm test

# --- Воркшоп-обвʼязка (заповнюється в блоках B8/B10) ---

doctor:
	@echo "doctor: буде додано в блоці B10 (preflight-автоматизація)"

preflight:
	@echo "preflight: буде додано в блоці B10"

# Usage: make seed TAG=t3
seed:
	@echo "seed: буде додано в блоці B8 (теги + дампи)"
