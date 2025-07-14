/*
Test all columns in a table for leading or trailing spaces.

Note: As leading or trailing spaces is related to text data,
      this macro will only test varchar datatypes.

Parameters:
	source_relation		the model being tested
    column_name         optional the column for a column base test

Developer: Steve Clarke
Revision History: 20220914      Macro created
*/
{% test leading_or_trailing_spaces(model, column_name=none) %}
{% if flags.WHICH in ('test', 'build') %}
{# Define variables #}
{% set col_value_dict = {} -%}
{%- set source_schema = model.schema %}
{%- set source_object = model.name %}

{%- set info_col_table = adapter.get_relation(
      database=model.database,
      schema='information_schema',
      identifier='columns') -%}
      
{%- call statement('info_query', fetch_result=true) -%}

    select 
        lower(column_name) as "column_name",
        lower(data_type)   as "info_datatype",
        ordinal_position   as "ordinal_position"
    from {{ info_col_table }}
    where upper(table_schema) = upper('{{ source_schema }}')
        and upper(table_name) = upper('{{ source_object }}')
        and lower(data_type) = 'text'
        {% if column_name %}
        and column_name ilike any ('{{ column_name }}')
        {% endif %}
{%- endcall -%}

{%- set results = load_result('info_query')['table'] -%}
{%- set row_list = [] -%}

{%- if execute -%}

    {%- for row in results.rows -%}
   
        {%- set row_value = row['column_name'] -%}
        {%- do row_list.append(row_value) -%}

    {%- endfor -%}

    {%- if row_list | length == 0 -%}
        {%- do exceptions.warn('\nWarning: Error no text columns detected in data source ' ~ source_relation ~ '\n') -%}
    {%- endif -%}

    {% call statement('check_result_qry', fetch_result=true) -%}
        with
        compare_records as
        (
            select
        {{- '\n\t\t\t' -}}

        {%- for row in row_list -%}
            {{- '\t\t\t' if not loop.first else '' -}}
            {{- 'case when rtrim(' ~ row ~ ') <> ' ~ row ~ ' then 1 else 0 end as count_rtrim_' ~ row -}}
            {{- ',\n\t\t\t' -}}
            {{- 'case when ltrim(' ~ row ~ ') <> ' ~ row ~ ' then 1 else 0 end as count_ltrim_' ~ row -}}
            {{- ',\n' if not loop.last else '' -}}
        {%- endfor -%}

        {{- '\n\t\t' -}}
        from {{ model }}
        )
        {{- '\n' -}}
        
        , column_error_count as
        (
            select
        {{- '\n\t\t\t' -}}

        {%- for row in row_list -%}
            {{- '\t\t\t' if not loop.first else '' -}}
            {{- 'sum(count_rtrim_' ~ row ~ ') as count_rtrim_' ~ row -}}
            {{- ',\n\t\t\t' -}}
            {{- 'sum(count_ltrim_' ~ row ~ ') as count_ltrim_' ~ row -}}
            {{- ',\n' if not loop.last else '' -}}
        {%- endfor -%}

        {{- '\n\t\t' -}}
        from compare_records
        )
        {{- '\n' -}}

        select *
        from column_error_count
    {% endcall -%}

    {# Output the SQL query results to an agate table format #}
    {% set check_result = load_result('check_result_qry')['table'] -%}

    {# Populate a dictionary with column name and corresponding value where the value > 0 indicating -1 keys have been detected #}
    {% for cols in check_result.columns -%}
        {% if cols.values()[0]|int > 0 %}
            {%- do col_value_dict.update({cols.name: cols.values()[0]}) -%}
        {% endif -%}
    {% endfor -%}

{%- endif -%}

{# If the dictionary is populated i.e. length > 0, then trim issues have been detected and will be output to the log and trigger a test error #}
{% if col_value_dict | length > 0 -%}
    {% for column_name, column_value in col_value_dict.items() -%}
        {% if loop.first -%}
            {{ log("###############################################################################", True) }}
            {{ log("## The following columns have unresolved ltrim or rtrim issues", True) }}
            {{ log("##", True) }}
            {{ log("##   Model name: " ~ model, True) }}
            {{ log("##", True) }}
            {{ log("##    " ~ "Column Name".ljust(50,' ') ~ "| Affected Row Count", True) }}
            {{ log("##    " ~ "-----------".ljust(50,'-') ~ "--------------------", True) }}
        {% endif -%}
  
        {# Set integer value to string so it can be right justified and padded #}
        {% set column_value_string = column_value | string -%}
        {{ log("##    " ~ column_name.ljust(50,' ') ~ "| " ~ column_value_string.rjust(18,' '), True) }}

        {% if loop.last -%}
            {{ log("##", True) }}
            {{ log("###############################################################################", True) }}
        {% endif -%}
  
    {%- endfor -%}

    {# Generate a row for each column that failed the test so the log reports the correct number of test failures#}
    {% for i in col_value_dict -%}
        select 1 as row_count {% if not loop.last %}union all{% endif %}
    {% endfor -%}
{% else -%}
    {# Return 0 rows to pass the test #}
    select 0 where 0=1
{% endif -%}
{%- endif -%}
{%- endtest -%}
