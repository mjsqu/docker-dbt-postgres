select
{% for src in graph.sources.values() %}
'{{ src.database }}'
{% endfor %}