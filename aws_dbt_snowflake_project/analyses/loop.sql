{% set cols = ['BOOKING_ID', 'LISTING_ID', 'BOOKING_DATE'] %}

SELECT 
{% for col in cols %}
    {{col}}
    {% if not loop.last %},
    {% endif %}
{% endfor %}
FROM {{ref('bronze_bookings')}}

