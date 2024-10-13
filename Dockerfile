FROM ghcr.io/dbt-labs/dbt-postgres:latest
WORKDIR /code
RUN useradd -u 1000 -m bob
RUN dbt --version
ENTRYPOINT []
