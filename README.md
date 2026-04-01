# Dishly — Database

Database schema and migrations for the Dishly allergen management platform, using [golang-migrate](https://github.com/golang-migrate/migrate) and Docker.

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) and Docker Compose installed
- GNU Make
- Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

> **Note:** This Docker Compose setup is for **local development only**. It's the fastest way to get a working database on your machine. The production deployment will be handled by a self-hosted PaaS (e.g., Dokploy, Portainer, Coolify) with its own pipeline — you don't need to worry about that here.

## Quick Start

```bash
# 1. Start PostgreSQL
make up

# 2. Apply all migrations
make migrate-up

# 3. (Optional) Load seed data
make seed
```

## What Are Migrations?

Migrations are **versioned SQL scripts** that evolve the database schema over time. Instead of modifying the database by hand, every change (new table, new column, index, etc.) is written as a migration file that gets committed to Git.

This gives us:

- **Version control** — the schema has a history, just like code.
- **Reproducibility** — anyone can recreate the exact same database from scratch.
- **Collaboration** — no more "run this SQL I sent you on Slack". Everyone runs `make migrate-up` and gets the same result.
- **Rollback** — every migration has an `up` (apply) and a `down` (revert), so mistakes can be undone.

### How It Works in This Repo

We use **golang-migrate** running inside a Docker container — no need to install anything on your machine beyond Docker.

```
migrations/
├── 000001_create_core_allergen_tables.up.sql    ← applies the change
├── 000001_create_core_allergen_tables.down.sql   ← reverts the change
├── 000002_add_events_tables.up.sql               ← next migration (up)
├── 000002_add_events_tables.down.sql             ← next migration (down)
└── ...
```

Each migration is a pair of files:

| File | Purpose |
|------|---------|
| `NNNNNN_name.up.sql` | SQL to **apply** the change (CREATE TABLE, ALTER, etc.) |
| `NNNNNN_name.down.sql` | SQL to **revert** the change (DROP TABLE, ALTER DROP, etc.) |

The `NNNNNN` prefix is a sequential number. golang-migrate runs them in order and tracks which ones have already been applied in a `schema_migrations` table inside the database.

## Available Commands

| Command | What it does |
|---------|-------------|
| `make up` | Start PostgreSQL container |
| `make down` | Stop PostgreSQL container |
| `make migrate-up` | Apply **all** pending migrations |
| `make migrate-down` | Revert the **last** migration (one step back) |
| `make migrate-create` | Create a new migration (prompts for a name) |
| `make migrate-force` | Force the migration version (for fixing dirty state) |
| `make seed` | Load seed data from `seeds/seed.sql` |

## Common Workflows

### Starting fresh

```bash
make up
make migrate-up
```

This starts Postgres and applies every migration from `000001` to the latest. Your database is now identical to everyone else's.

### Creating a new migration

```bash
make migrate-create
# Prompt: Migration name: add_orders_table
```

This generates two empty files:

```
migrations/000002_add_orders_table.up.sql
migrations/000002_add_orders_table.down.sql
```

Edit both files — write the SQL to apply the change in `.up.sql` and the SQL to undo it in `.down.sql`. Then:

```bash
make migrate-up
```

### Reverting a migration

```bash
make migrate-down
```

This rolls back **one** migration. Run it multiple times to go further back.

### Fixing a dirty migration

If a migration fails halfway (e.g., syntax error in your SQL), golang-migrate marks the database as **dirty** and refuses to run anything. To fix it:

1. Manually fix whatever the failed migration left behind (drop partial tables, etc.)
2. Force the version back to the last clean state:

```bash
make migrate-force
# Prompt: Force version: 1    ← the last successfully applied version
```

3. Fix the broken migration file, then run `make migrate-up` again.

## Rules for Writing Migrations

1. **One concern per migration** — don't mix unrelated changes. "Add orders table" and "add allergen index" should be separate migrations.
2. **Always write the down file** — if your `up.sql` creates a table, your `down.sql` must drop it. This keeps rollbacks working.
3. **Never edit an applied migration** — once a migration is merged to `dev`, treat it as immutable. If you need to change something, create a new migration.
4. **Use IF NOT EXISTS / IF EXISTS** — makes migrations idempotent and safer to re-run.
5. **Test both directions** — run `make migrate-up`, then `make migrate-down`, then `make migrate-up` again. If it works, your migration is solid.

## Project Structure

```
ptin-database/
├── docker-compose.dev.yml   # PostgreSQL 17 Alpine (dev environment)
├── .env.example             # Environment variable template
├── .env                     # Local environment variables (git-ignored)
├── Makefile                 # All commands (up, down, migrate-*, seed)
├── migrations/              # Versioned SQL migration files
│   ├── 000001_*.up.sql
│   └── 000001_*.down.sql
└── seeds/                   # Optional seed data for development
    └── seed.sql
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `dishly` | Database user |
| `POSTGRES_PASSWORD` | `dishly_dev` | Database password |
| `POSTGRES_DB` | `dishly` | Database name |
| `POSTGRES_PORT` | `5432` | Port exposed on localhost |
