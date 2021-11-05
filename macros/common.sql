--creating full name by concatenating first and last name
{% macro full_name(firstName, lastName) %}
    ({{firstName}} || ' ' || {{lastName}})
{% endmacro %}