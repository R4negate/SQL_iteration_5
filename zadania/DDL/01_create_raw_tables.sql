DROP TABLE IF EXISTS raw.orders_raw;
DROP TABLE IF EXISTS raw.customers_raw;
DROP TABLE IF EXISTS raw.products_raw;
DROP TABLE IF EXISTS raw.order_items_raw;

CREATE TABLE raw.customers_raw (
    customer_id TEXT,
    customer_name TEXT,
    email TEXT,
    country TEXT,
    signup_date TEXT,
    acquisition_channel TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.products_raw (
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    base_price TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_date TEXT,
    status TEXT,
    total_amount TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.order_items_raw (
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    quantity TEXT,
    unit_price TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
