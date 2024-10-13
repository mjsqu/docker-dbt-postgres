# docker-dbt-postgres

## Instructions

```shell
git clone
cd docker-dbt-postgres
docker compose up -d
```

Use `docker container list` to verify dbt and postgres are up.

Shell into the dbt container

```shell
docker exec -it dbt bash
```

The proj directory is bind-mounted, edit files locally and submit dbt commands within the container