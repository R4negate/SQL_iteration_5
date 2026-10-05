SELECT 'raw.customers_raw' AS table_name, COUNT(*) AS rows_count FROM raw.customers_raw
UNION ALL
SELECT 'raw.products_raw', COUNT(*) FROM raw.products_raw
UNION ALL
SELECT 'raw.orders_raw', COUNT(*) FROM raw.orders_raw
UNION ALL
SELECT 'raw.order_items_raw', COUNT(*) FROM raw.order_items_raw;
