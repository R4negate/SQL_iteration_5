# Zadania 02 - fakty, wymiary i star schema

## Zadanie 1

Wyjasnij roznice miedzy tabela faktow a tabela wymiarow.

Podaj po dwa przyklady z naszego modelu e-commerce.

## Zadanie 2

Stworz schemat:

```sql
CREATE SCHEMA IF NOT EXISTS star;
```

## Zadanie 3

Stworz tabele `star.dim_customer`.

Kolumny:

- `customer_key`,
- `customer_id`,
- `customer_name`,
- `country`,
- `acquisition_channel`,
- `signup_date`.

Zasady:

- `customer_key` ma byc kluczem sztucznym,
- `customer_id` ma byc naturalnym kluczem ze zrodla.

## Zadanie 4

Stworz tabele `star.dim_product`.

Kolumny:

- `product_key`,
- `product_id`,
- `product_name`,
- `category`,
- `base_price`.

## Zadanie 5

Stworz tabele `star.dim_date`.

Kolumny:

- `date_key`,
- `full_date`,
- `year`,
- `month`,
- `day`,
- `month_name`,
- `is_weekend`.

Wygeneruj daty od `2026-01-01` do `2026-12-31`.

## Zadanie 6

Zaladuj dane do tabel wymiarow.

Uzyj tabel:

- `staging.stg_customers`,
- `staging.stg_products`.

## Zadanie 7

Stworz tabele `star.fact_order_items`.

Grain:

```text
jeden wiersz = jedna pozycja zamowienia
```

Kolumny:

- `order_item_id`,
- `order_id`,
- `customer_key`,
- `product_key`,
- `date_key`,
- `status`,
- `quantity`,
- `unit_price`,
- `line_revenue`.

## Zadanie 8

Zaladuj dane do tabeli `star.fact_order_items`.

Uzyj:

- `staging.stg_order_items`,
- `staging.stg_orders`,
- `star.dim_customer`,
- `star.dim_product`,
- `star.dim_date`.

## Zadanie 9

Napisz raport ze star schema:

```text
miesieczna sprzedaz per kategoria produktu
```

Wynik powinien zawierac:

- `year`,
- `month`,
- `category`,
- `units_sold`,
- `total_revenue`.

## Zadanie 10

Napisz raport ze star schema:

```text
sprzedaz per kraj klienta i miesiac
```

Wynik powinien zawierac:

- `year`,
- `month`,
- `country`,
- `orders_count`,
- `total_revenue`.

Pamietaj, ze grain faktu to pozycja zamowienia, wiec do liczenia zamowien uzyj `COUNT(DISTINCT order_id)`.

## Zadanie 11

Napisz query, ktore pokazuje roznice miedzy:

- `COUNT(order_id)`,
- `COUNT(DISTINCT order_id)`.

Wyjasnij, dlaczego te liczby moga byc rozne na tabeli `star.fact_order_items`.

## Zadanie 12

Napisz to samo pytanie co w zadaniu 9 bez star schema, korzystajac ze stagingu.

Porownaj liczbe joinow i czytelnosc query.

