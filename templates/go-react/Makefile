.PHONY: up down logs check api-check web-check

# --- Повний локальний стек ---

up:
	docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

# --- Наскрізна перевірка (чистий clone -> make check зелений) ---

CHECK_TARGETS := api-check
# battery:web
CHECK_TARGETS += web-check
# /battery:web

check: $(CHECK_TARGETS)

api-check:
	$(MAKE) -C api check

# battery:web
web-check:
	cd web && (test -d node_modules || npm ci) && npm run typecheck && npm test
# /battery:web
