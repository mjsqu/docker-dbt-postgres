FROM ghcr.io/dbt-labs/dbt-postgres:latest
RUN useradd -u 1000 -m bob
RUN python -m pip install --upgrade pip dbt-core
