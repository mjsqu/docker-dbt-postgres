# docker-dbt-postgres

## Purpose

A repository for dbt training, development and debugging.

## Instructions

This repository works really well with GitHub codespaces, or clone the repository locally:

```shell
git clone
cd docker-dbt-postgres
```

Set up a `.env` file at the root of the repository. The `.env` file should contain values for `UID` and `GID` (see sample below) - these can be obtained from the `id` command:

```shell
id
```

Sample output:
```shell
uid=1000(codespace) gid=1000(codespace) groups=1000(codespace)...
```

Populate the .env file with the outputs of the `id` command and some settings for PostgreSQL, for example:

```.env
UID=1000
GID=1000
POSTGRES_SCHEMA=my_test_schema
POSTGRES_USER=dbt_tester
POSTGRES_PASSWORD=1fbe12f5-6bca-4269-88d6-fce348d4360e
```

With the `.env` file contents saved, run the following command to download container images (if required), start up the database (named: dbt_db) and dbt containers.

```shell
docker compose up -d
```

The `dbt` container has `dbt-core` installed on it and can run dbt commands. It has a project which contains connection information allowing it to connect to the `dbt_db` container which is running a PostgreSQL database.

Tip: List active containers using this command:

```shell
docker container list
```

to verify dbt and PostgreSQL (dbt_db) are up.

To "shell into" the dbt container and run dbt commands:

```shell
docker exec -it dbt bash
```

You can now edit the project stored in the `proj` directory and run dbt commands.

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

## Bind mountings

The following directories are mounted into each container. This means that edits within the container or outside should be synced back and forth. You can edit files locally and from a shell in the container, run commands that use those files.

|local directory|container|remote directory|
|--|--|
|proj|dbt|/code/proj|
|sql_scripts|/home/sql_scripts|

## Sample projects

The `main` branch contains a skeleton of a project with no models, macros, tests etc.

Branches will be added to this repository with sample projects and tutorials.

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
