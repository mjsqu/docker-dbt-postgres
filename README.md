# docker-dbt-postgres

## Purpose

A repository for dbt training, development and debugging.

## Instructions

This repository works really well with GitHub codespaces, or clone the repository locally:

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

:warning: N.B. `POSTGRES_PASSWORD` cannot be left blank - make something up!

```shell
docker compose up -d
```

Use `docker container list` to verify dbt and postgres are up.

Shell into the dbt container

```shell
docker exec -it dbt bash
```

The `proj` directory is bind-mounted, edit files locally and submit dbt commands within the container

## Running PostgreSQL

To query data directly you can shell into the `dbt_db` container:
```shell
docker exec -it dbt_db bash
```

The `./sql_scripts` directory is mounted into `./home` in the `dbt_db` container - add your own scripts and run, e.g.:

```shell
postgres@dbt_db:/home/sql_scripts$ psql -U dbt_tester postgres -f samples/information_schema_query.sql
```

Which should return:

|    table_schema    |              table_name               | table_type |
|--------------------|---------------------------------------|------------|
| pg_catalog         | pg_statistic                          | BASE TABLE |
| pg_catalog         | pg_type                               | BASE TABLE |
| pg_catalog         | pg_foreign_table                      | BASE TABLE |
| pg_catalog         | pg_authid                             | BASE TABLE |
| pg_catalog         | pg_shadow                             | VIEW       |

Alternatively, log in without `-f` to run quick queries:
```shell
postgres@dbt_db:/home/sql_scripts$ psql -U dbt_tester postgres
```

## Tips

### UI Tip

Splitting across two terminals active in both container images can help check the results of model builds on actual data.

### VSCode Keybindings

You can set up a keybinding for compiling macros in VSCode:

```json
// Place your key bindings in this file to override the defaults
[{
    "key": "ctrl+shift+enter",
    "command": "workbench.action.terminal.sendSequence",
    "args": { "text": "dbt compile -s '${fileBasename}'\u000D" }
}
]
```

With a model open in your editor window, you can push Ctrl+Shift+Enter (or your choice of keybinding) to run `dbt compile -s` for that file and view the output in the terminal.

## Troubleshooting

```
WARN[0000] The "UID" variable is not set. Defaulting to a blank string. 
WARN[0000] The "GID" variable is not set. Defaulting to a blank string. 
env file /workspaces/docker-dbt-postgres/.env not found: stat /workspaces/docker-dbt-postgres/.env: no such file or directory
```

Go back and add the `.env` file and ensure it has values for UID, GID
