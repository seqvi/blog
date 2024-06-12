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

## Разное

### сгенерить ключ в 64 символа

```bash
  docker run authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric
```

```bash
  openssl rand -hex 64
```

```bash
LENGTH=64
tr -cd '[:alnum:]' < /dev/urandom | fold -w "${LENGTH}" | head -n 1 | tr -d '\n' ; echo
```

### RSA Key pair

```bash
    docker run -u "$(id -u):$(id -g)" -v "$(pwd)":/keys authelia/authelia:latest authelia crypto pair rsa generate --bits 4096 --directory /keys
```

```bash
    openssl genrsa -out private.pem 4096
    openssl rsa -in private.pem -outform PEM -pubout -out public.pem
```


### RSA Self-Signed Certificate

```bash
  docker run -u "$(id -u):$(id -g)" -v "$(pwd)":/keys authelia/authelia:latest authelia crypto certificate rsa generate --common-name example.com --directory /keys
```

```bash
  openssl req -x509 -nodes -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -subj '/CN=example.com'
```

### password generating (user_db.yml file)

```bash
  docker run --rm authelia/authelia:latest authelia crypto hash generate --random argon2
 ```

### usr db file template

```yaml
users:
  john:
    disabled: false
    displayname: 'John Doe'
    password: '$argon2id$v=19$m=65536,t=3,p=2$BpLnfgDsc2WD8F2q$o/vzA4myCqZZ36bUGsDY//8mKUYNZZaR0t4MFFSs+iM'
    email: 'john.doe@authelia.com'
    groups:
      - 'admins'
      - 'dev'
  harry:
    disabled: false
    displayname: 'Harry Potter'
    password: '$argon2id$v=19$m=65536,t=3,p=2$BpLnfgDsc2WD8F2q$o/vzA4myCqZZ36bUGsDY//8mKUYNZZaR0t4MFFSs+iM'
    email: 'harry.potter@authelia.com'
    groups: []
  bob:
    disabled: false
    displayname: 'Bob Dylan'
    password: '$argon2id$v=19$m=65536,t=3,p=2$BpLnfgDsc2WD8F2q$o/vzA4myCqZZ36bUGsDY//8mKUYNZZaR0t4MFFSs+iM'
    email: 'bob.dylan@authelia.com'
    groups:
      - 'dev'
  james:
    disabled: false
    displayname: 'James Dean'
    password: '$argon2id$v=19$m=65536,t=3,p=2$BpLnfgDsc2WD8F2q$o/vzA4myCqZZ36bUGsDY//8mKUYNZZaR0t4MFFSs+iM'
    email: 'james.dean@authelia.com'
    groups: []
```