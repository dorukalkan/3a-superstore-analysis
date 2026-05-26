select
    order_detail_id,
    paid_line_amount,
    amount,
    effective_paid_unit_price
from {{ ref('int_order_line_pricing') }}
where abs(effective_paid_unit_price - safe_divide(paid_line_amount, cast(amount as numeric))) > 0.000001
