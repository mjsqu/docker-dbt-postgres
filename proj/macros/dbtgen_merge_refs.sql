{%- macro dbtgen_merge_refs(source_system_name) -%}
{#- A dbtgen-specific invocation of the merge_refs macro -#}
{#- Finds and merges the dbtgen_table and dbtgen_column seeds -#}
{#- Allows for hierarchichal merging of refs, where one could be empty -#}
{#- Returns {"TABLE":..,"COLUMN":..} object for use downstream, plus the original dwh_source parameter values -#}

{%- set refs = {
    'table': ref('land_raw__'~ source_system_name ~'__dbtgen_table'),
    'column': ref('land_raw__'~ source_system_name ~'__dbtgen_column'),
} -%}
{%- set res = {} -%}
{%- for key, ref_obj in refs.items() -%}
{{ key }}
{{ ref_obj }}
{%- set cols = adapter.get_columns_in_relation(ref_obj) | map(attribute="column") -%}
{%- set query -%}
select
{% for col in cols -%}
    "{{ col }}"{%- if not loop.last -%},{%- endif -%}
{%- endfor %}
from
    {{ ref_obj }}
{%- endset -%}
{%- do res.update({key: dbt_utils.get_query_results_as_dict(query)}) -%}
{#%- do res.update({key: query}) -%#}
{%- endfor -%}
{%- set table_res = res['table']-%}
{%- set column_res = res['column'] -%}

{{ return(
    {
        "TABLE": table_res,
        "COLUMN": column_res,
        "source_system_name": source_system_name,
    }
) }}

{%- endmacro -%}
