# Instrument Practice App

A Docker-based monorepo for recording musical instrument practice. The initial
environment contains a Next.js frontend, a Django REST Framework backend, and
PostgreSQL. Application models are intentionally not included yet.

## Prerequisites

- Docker Desktop or Docker Engine with Docker Compose v2

## Start the development environment

1. Create your local environment file:

   ```sh
   cp .env.example .env
   ```

   On PowerShell, use `Copy-Item .env.example .env`.

2. Replace the example password and Django secret in `.env`.

3. Build and start all services:

   ```sh
   docker compose up --build
   ```

4. Open the services:

   - Frontend: http://localhost:3000
   - Backend health check: http://localhost:8000/api/health/

The backend applies Django's built-in migrations when it starts. A successful
health response includes `"database": "ok"`, confirming that Django can query
PostgreSQL.

## Useful commands

View service status:

```sh
docker compose ps
```

View logs:

```sh
docker compose logs -f
```

Stop the services without deleting database data:

```sh
docker compose down
```

Run Django checks:

```sh
docker compose exec backend python manage.py check
```

The PostgreSQL data is stored in the named `postgres_data` volume. Running
`docker compose down` leaves it intact.

## Development workflow

See [Branching Strategy](docs/branching-strategy.md) for branch naming, pull
request, merge, and release rules.
