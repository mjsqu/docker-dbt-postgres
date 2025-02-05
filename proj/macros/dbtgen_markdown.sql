{%- macro dbtgen_markdown(source_system_name) -%}
    {#- Returns the markdown files for a given source.

    Args:
        source_system_name: The source system for which to create markdown files.

    Returns:
        A dict mapping filenames to the corresponding file content
        as a list.

    Raises:
     
    -#}

{%- set markdown_file_root_folder = (['models','land'] | join('/')) -%}

{% set markdown_files = {} %}
{%- set schema_parts = [source_system_name] -%}
{%- set path_parts = [markdown_file_root_folder,source_system_name] -%}

{%- set seed_schema = (schema_parts | join('_')) -%}
{%- set doc_prefix = ['land',seed_schema] | join('__') -%}

{%- set table_seed = ref('land_raw__'~ seed_schema ~'__dbtgen_table') -%}
{%- set column_seed = ref('land_raw__'~ seed_schema ~'__dbtgen_column') -%}

{%- set markdown_file = (
        path_parts
        +
        [
            'docs',
            doc_prefix~'.md'
        ]
        ) | join('/') 
-%}

{%- 
    do markdown_files.update(
        {
            markdown_file: (
                dbtgen_markdown_file_content(table_seed, doc_prefix) + 
                dbtgen_markdown_file_content(column_seed, doc_prefix)
                )
        }
    ) 
-%}

{{ return(markdown_files) }}
{%- endmacro -%}
