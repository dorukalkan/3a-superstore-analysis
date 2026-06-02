select
    order_detail_id,
    amount,
    source_unit_price,
    paid_line_amount,
    effective_paid_unit_price
from {{ ref('int_order_line_pricing') }}
where amount <= 0
    or source_unit_price <= 0
    or paid_line_amount <= 0
    or effective_paid_unit_price <= 0
