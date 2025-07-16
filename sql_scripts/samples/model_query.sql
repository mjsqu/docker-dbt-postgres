/* Run dbt build on the sample model first */
/* dbt build --select info_schema_tables */
select 
    *
from 
    /* Schema name is derived from .env */
    "my_test_schema"."info_schema_tables"
;
