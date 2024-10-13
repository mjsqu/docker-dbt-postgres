# docker-dbt-postgres

## Instructions

```shell
git clone
cd docker-dbt-postgres
touch .env
id
```

Populate the .env file with the outputs of the id command and some settings for postgres:

```.env
UID=1000
GID=1000
POSTGRES_SCHEMA=my_test_schema
POSTGRES_USER=dbt_tester
POSTGRES_PASSWORD=
```

```shell
docker compose up -d
```

Use `docker container list` to verify dbt and postgres are up.

Shell into the dbt container

```shell
docker exec -it dbt bash
```

The proj directory is bind-mounted, edit files locally and submit dbt commands within the container
