select *
from {{ source('raw', 'orders') }}
limit 100