--creating full name by concatenating first and last name
{% macro full_name(firstName, lastName) %}
    (COALESCE({{firstName}},'') || ' ' || COALESCE({{lastName}},''))
{% endmacro %}

{% macro set_query_tag() -%}

  {% set project_tag = model.package_name %} 
  {% set new_query_tag = model.name %} 
  

  {% if new_query_tag %}
    {% set original_query_tag = get_current_query_tag() %}
    {{ log("Setting query_tag to '{0}'. Will reset to '{1}' after materialization.".format(new_query_tag, original_query_tag)) }}
    {% do run_query("alter session set query_tag = 'dbt|{}|{}'".format(project_tag,new_query_tag)) %}
    {{ return(original_query_tag)}}
  {% endif %}
  {{ return(none)}}

{% endmacro %}