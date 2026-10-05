# Zadania 01 - ETL/ELT, OLTP/OLAP i warstwy danych

## Zadanie 1

Wyjasnij roznice miedzy `ETL` i `ELT` na przykladzie danych zamowien.

W odpowiedzi uwzglednij:

- gdzie trafiaja dane surowe,
- kiedy odbywa sie transformacja,
- ktore podejscie lepiej pasuje do warstw `raw -> staging -> core -> mart`.

## Zadanie 2

Dla ponizszych sytuacji napisz, czy to bardziej `OLTP`, czy `OLAP`.

1. Aplikacja zapisuje nowe zamowienie klienta.
2. Dashboard pokazuje miesieczna sprzedaz per kraj.
3. System aktualizuje email klienta.
4. Analityk liczy TOP 5 produktow po przychodzie.
5. System platnosci zapisuje status transakcji.

## Zadanie 3

Napisz, jaki jest grain tabel:

- `raw.customers_raw`,
- `raw.orders_raw`,
- `raw.order_items_raw`,
- `raw.products_raw`.

## Zadanie 4

Stworz tabele `staging.stg_customers` na podstawie `raw.customers_raw`.

Zasady:

- `customer_id` ma byc typu `INT`,
- `signup_date` ma byc typu `DATE`,
- `country` ma byc zapisany wielkimi literami,
- `acquisition_channel` ma byc zapisany malymi literami,
- usun duplikaty klientow po `customer_id`.

## Zadanie 5

Stworz tabele `staging.stg_orders` na podstawie `raw.orders_raw`.

Zasady:

- `order_id` i `customer_id` maja byc typu `INT`,
- `order_date` ma byc typu `DATE`,
- `total_amount` ma byc typu `NUMERIC(10, 2)`,
- `status` ma byc zapisany malymi literami,
- usun duplikaty zamowien po `order_id`.

## Zadanie 6

Stworz tabele `staging.stg_products` na podstawie `raw.products_raw`.

Zasady:

- `product_id` ma byc typu `INT`,
- `base_price` ma byc typu `NUMERIC(10, 2)`,
- `category` ma byc zapisane malymi literami,
- usun duplikaty po `product_id`.

## Zadanie 7

Stworz tabele `staging.stg_order_items` na podstawie `raw.order_items_raw`.

Zasady:

- `order_item_id`, `order_id`, `product_id`, `quantity` maja byc typu `INT`,
- `unit_price` ma byc typu `NUMERIC(10, 2)`,
- dodaj kolumne `line_value` jako `quantity * unit_price`,
- usun duplikaty po `order_item_id`.

## Zadanie 8

Stworz tabele `core.orders_enriched`.

Wynik powinien zawierac:

- `order_id`,
- `customer_id`,
- `customer_name`,
- `country`,
- `acquisition_channel`,
- `order_date`,
- `status`,
- `total_amount`,
- `is_paid`.

Uzyj danych ze stagingu.

## Zadanie 9

Stworz tabele `mart.daily_revenue_by_country`.

Wynik powinien zawierac:

- `revenue_date`,
- `country`,
- `orders_count`,
- `paid_orders_count`,
- `cancelled_orders_count`,
- `total_revenue`.

Zasady:

- grain tabeli to jeden dzien i jeden kraj,
- `total_revenue` ma liczyc tylko zamowienia `paid`.

## Zadanie 10

Napisz, ktore tabele z poprzednich zadan sa odpowiednikami:

- raw,
- staging,
- core,
- mart,
- bronze,
- silver,
- gold.

## Zadanie 11

Napisz jednym zdaniem, dlaczego `raw` nie powinno byc uzywane bezposrednio w dashboardzie.

## Zadanie 12

Napisz jednym zdaniem, czym rozni sie `staging` od `core`.

