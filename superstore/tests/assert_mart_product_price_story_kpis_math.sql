select
    *
from {{ ref('mart_product_price_story_kpis') }}
where abs(
        median_effective_paid_unit_price_pct_change
        - (
            safe_divide(
                comparison_median_effective_paid_unit_price,
                base_median_effective_paid_unit_price
            ) - 1
        )
    ) > 0.000001
    or abs(
        items_with_increased_effective_paid_price_pct
        - safe_divide(items_with_increased_effective_paid_price, eligible_item_count)
    ) > 0.000001
    or eligible_item_count
        != items_with_increased_effective_paid_price
        + items_with_unchanged_effective_paid_price
        + items_with_decreased_effective_paid_price
