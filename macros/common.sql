{% macro full_name(firstName, lastName) %}
    ({{firstName}} || ' ' || {{lastName}})
{% endmacro %}