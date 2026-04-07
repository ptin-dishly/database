include .env
export

DATABASE_URL := postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable
MIGRATE_CMD := docker run --rm --network=host -v $(CURDIR)/migrations:/migrations migrate/migrate:v4.18.1

.PHONY: up down migrate-up migrate-down migrate-force migrate-create seed

up:
	docker compose -f docker-compose.dev.yml up -d

down:
	docker compose -f docker-compose.dev.yml down

migrate-up:
	$(MIGRATE_CMD) -path=/migrations -database "$(DATABASE_URL)" up

migrate-down:
	$(MIGRATE_CMD) -path=/migrations -database "$(DATABASE_URL)" down 1

migrate-force:
	@read -p "Force version: " version; \
	$(MIGRATE_CMD) -path=/migrations -database "$(DATABASE_URL)" force $$version

migrate-create:
	@read -p "Migration name: " name; \
	$(MIGRATE_CMD) create -ext sql -dir /migrations -seq $$name

seed:
	docker compose -f docker-compose.dev.yml exec -T db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /dev/stdin < seeds/seed.sql
