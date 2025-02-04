{%- macro dbtgen_markdown_file_content(seed, doc_prefix) -%}
    {#- Returns markdown file for a given seed

    Args:
        seed: A ref which points to a dbtgen seed
        doc_prefix: The prefix to add to each markdown doc block key (e.g. system or system_instance)

    Returns:
        A list of lines for markdown files.

    Raises:
     
    -#}
{%- set seed_content = dbt_utils.get_query_results_as_dict("select * from " ~ seed) -%}

{%- set markdown_content = [] -%}

{%- if 'DESCRIPTION' in seed_content -%}
{%- for row_number in range(seed_content['TABLE_NAME'] | length) -%}
    {%- set table_name = seed_content['TABLE_NAME'][row_number] -%}
    {%- set description = seed_content['DESCRIPTION'][row_number] -%}
    {%- set doc_block_key = [doc_prefix,table_name] -%}
    
    {%- 
        do doc_block_key.append(
            seed_content['COLUMN_NAME'][row_number]
        ) 
        if 'COLUMN_NAME' in seed_content 
    -%}
    
    {%- 
        do markdown_content.append(
            '{%- docs '~ (doc_block_key | join('__')) ~' -%}'~description~'{%- enddocs -%}'
        ) if description != None
    -%}

{%- endfor -%}
{%- else -%}
    {{ log("WARNING: " ~ seed ~ "did not contain a DESCRIPTION column, check columns and set to uppercase") }}
{%- endif-%}   

{{ return(markdown_content) }}
{%- endmacro -%}
