# BlogCMS

Hobby project for personal use. Free to fork and modifications of all kind. No support or maintenance.

## Configuration

### Postgres

Set `.env` file as this:


``` bash
POSTGRES_USER=user-name-for-pg
POSTGRES_PW=password-for-pg
POSTGRES_DB=your-local-test-db
PGADMIN_MAIL=pg-admin-email-can-be-fake
PGADMIN_PW=pg-admin-password
```

## Launch

just do `docker compose up -d` and go to http://localhost:5000.