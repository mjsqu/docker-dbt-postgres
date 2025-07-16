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

N.B. `POSTGRES_PASSWORD` cannot be left blank - make something up!

```shell
docker compose up -d
```

Use `docker container list` to verify dbt and postgres are up.

Shell into the dbt container

```shell
docker exec -it dbt bash
```

The proj directory is bind-mounted, edit files locally and submit dbt commands within the container

## Tips

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
