{%- macro dbtgen_yaml(source_system_name, folder, layer) -%}
    {#- Returns the YAML files for a given pair of merged seeds, folder and layer

    Args:
        source_system_name: The name of the source system to generate YAML for
        folder: The source folder, e.g. models, seeds, snapshot
        layer: The layer name, e.g. land, raw, persist

    Returns:
        A dict mapping filenames to the corresponding file content
        as a list.

    Raises:
     
    -#}

{%- set docprefix = ['land'] -%}

{%- set yaml_files = {} -%}

{%- set path = [folder,layer,source_system_name] -%}
{%- do path.append("docs") -%}

{%- set schema_name_parts = [source_system_name] -%}
{%- set schema_name = schema_name_parts | join('_') -%}

{%- set merged_seeds = dbtgen_merge_refs(source_system_name) -%}

{%- set table_seed_content = merged_seeds['TABLE'] %}
{%- set column_seed_content = merged_seeds['COLUMN'] %}

{%- for table_seed_row in range(table_seed_content['TABLE_NAME']|length) -%}
    {%- set table = table_seed_content['TABLE_NAME'][table_seed_row] -%}
    {%- set table_description = table_seed_content['DESCRIPTION'][table_seed_row] %}
    
    {%- set docprefix = ['land'] -%}
    {%- do docprefix.append(schema_name) -%}
    
    {%- set filestem = ([layer,schema_name,table] | join("__")) -%}
    {%- set filename = filestem ~ ".yml" -%}
    {%- set filepath = (path + [filename]) | join('/') -%}
    
    {%- set filecontent = {
        "version": 2, 
        folder : [
            {
                "name": filestem,
                "description":"",
                "columns": []
            }
        ]
    } 
    -%}

    {%- do filecontent[folder][0].update({"description":"{{ doc('" ~ ((docprefix+[table]) | join('__')) ~ "') }}}"}) if table_description != None -%}

    {%- for column_seed_row in range(column_seed_content["COLUMN_NAME"]|length) -%}
        {%- set table_name = column_seed_content["TABLE_NAME"][column_seed_row] -%}
        {%- if "DESCRIPTION" in column_seed_content -%}
            {%- set column_description = column_seed_content["DESCRIPTION"][column_seed_row] -%}
        {%- else -%}
            {%- set column_description = None -%}
        {%- endif -%}
        {%- if 
            table_name == table_seed_content["TABLE_NAME"][table_seed_row] 
        -%}
            {%- set column_name = column_seed_content["COLUMN_NAME"][column_seed_row] -%}

            {%- set docprefix = ['land'] -%}
            {%- do docprefix.append(schema_name) -%}

            {%- set column_definition = {"name": column_name} -%}
            {%- if column_seed_content.get('META__DATABASE_TAGS__PI') != None -%}
                {%- set pi_tag = column_seed_content['META__DATABASE_TAGS__PI'][column_seed_row] -%}
                {%- 
                    do column_definition.update(
                        {
                            "meta":{
                                "database_tags":{
                                    "pi": column_seed_content['META__DATABASE_TAGS__PI'][column_seed_row]
                                }
                            }
                        }
                    ) 
                if pi_tag != None
                -%}
            {%- endif -%}
            {%- 
                do column_definition.update(
                    {
                        "description":
                        "{{ doc('" ~ ((docprefix+[table_name,column_name]) | join('__')) ~ "') }}"
                    }
                ) 
                if column_description != None
            -%}
            {%- do filecontent[folder][0]["columns"].append(column_definition) -%}
        {%- endif -%}
    {%- endfor -%}
    {%- do yaml_files.update({filepath:filecontent}) -%}
{%- endfor -%}

{{ return(yaml_files) }}
{%- endmacro -%}
