INSERT INTO raw.customers_raw (
    customer_id,
    customer_name,
    email,
    country,
    signup_date,
    acquisition_channel
)
VALUES
    ('1', 'Anna Kowalska', 'anna@example.com', 'pl', '2026-01-05', 'google'),
    ('2', 'Jan Nowak', 'jan@example.com', 'PL', '2026-01-08', 'facebook'),
    ('3', 'Maria Zielinska', 'maria@example.com', 'de', '2026-02-10', 'newsletter'),
    ('4', 'Tom Smith', NULL, 'us', '2026-02-12', 'google'),
    ('5', 'Eva Muller', 'eva@example.com', 'DE', '2026-03-01', 'organic'),
    ('5', 'Eva Muller', 'eva@example.com', 'DE', '2026-03-01', 'organic');

INSERT INTO raw.products_raw (
    product_id,
    product_name,
    category,
    base_price
)
VALUES
    ('10', 'SQL Starter', 'course', '99.00'),
    ('11', 'Python Starter', 'course', '129.00'),
    ('12', 'Analytics Template', 'template', '49.00'),
    ('13', 'Data Modeling Pack', 'course', '159.00');

INSERT INTO raw.orders_raw (
    order_id,
    customer_id,
    order_date,
    status,
    total_amount
)
VALUES
    ('100', '1', '2026-03-01', 'PAID', '99.00'),
    ('101', '1', '2026-03-12', 'paid', '49.00'),
    ('102', '2', '2026-03-15', 'cancelled', '129.00'),
    ('103', '3', '2026-04-02', 'paid', '208.00'),
    ('104', '5', '2026-04-08', 'pending', '159.00'),
    ('104', '5', '2026-04-08', 'pending', '159.00');

INSERT INTO raw.order_items_raw (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES
    ('1000', '100', '10', '1', '99.00'),
    ('1001', '101', '12', '1', '49.00'),
    ('1002', '102', '11', '1', '129.00'),
    ('1003', '103', '10', '1', '99.00'),
    ('1004', '103', '12', '1', '49.00'),
    ('1005', '103', '13', '1', '60.00'),
    ('1006', '104', '13', '1', '159.00');
