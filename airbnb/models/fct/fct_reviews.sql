{{
    config(
        materialized = 'incremental',
        on_schema_change = 'fail'
    )

}}


WITH src_reviews AS (
  SELECT * FROM {{ ref('src_raw_reviews') }}
)
SELECT
  {{ dbt_utils.generate_surrogate_key(['listing_id', 'review_date', 'reviewer_name', 'review_comments']) }}
    AS review_id,
  *
  FROM src_reviews
WHERE review_comments is not null

{% if is_incremental() %}
  AND review_date > (select max(review_date) f
  from {{ this }})
{% endif %}
