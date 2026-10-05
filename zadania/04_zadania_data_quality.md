# Zadania 04 - data quality i reconciliation

## Zadanie 1

Napisz query, ktore sprawdza, czy `staging.stg_orders.order_id` ma wartosci `NULL`.

## Zadanie 2

Napisz query, ktore sprawdza, czy `staging.stg_orders` ma duplikaty po `order_id`.

Wynik powinien zawierac:

- `order_id`,
- `rows_count`.

## Zadanie 3

Napisz query, ktore pokazuje statusy inne niz:

- `paid`,
- `pending`,
- `cancelled`.

## Zadanie 4

Napisz query, ktore pokazuje zamowienia z ujemna albo zerowa wartoscia `total_amount`.

## Zadanie 5

Napisz query, ktore sprawdza, czy kazde zamowienie ze `staging.stg_order_items` istnieje w `staging.stg_orders`.

Wynik powinien pokazac pozycje zamowien bez pasujacego zamowienia.

## Zadanie 6

Napisz query, ktore sprawdza, czy kazdy produkt ze `staging.stg_order_items` istnieje w `staging.stg_products`.

Wynik powinien pokazac pozycje zamowien z nieznanym produktem.

## Zadanie 7

Napisz query, ktore sprawdza klientow bez emaila w `staging.stg_customers`.

## Zadanie 8

Napisz query, ktore sprawdza, czy `staging.stg_order_items` ma ilosci `quantity <= 0`.

## Zadanie 9

Napisz reconciliation query, ktore porownuje:

- sume zamowien `paid` ze `staging.stg_orders`,
- sume sprzedazy z `mart.daily_revenue_by_country`.

Wynik powinien zawierac:

- `source_name`,
- `total_revenue`.

Uzyj `UNION ALL`.

## Zadanie 10

Napisz query, ktore pokazuje roznice miedzy suma `paid` ze stagingu a suma z martu.

Wynik powinien zawierac:

- `staging_paid_revenue`,
- `mart_revenue`,
- `difference_amount`.

## Zadanie 11

Napisz query, ktore sprawdza duplikaty w `mart.daily_revenue_by_country` po grainie:

```text
revenue_date + country
```

## Zadanie 12

Przygotuj jeden raport kontrolny przez `UNION ALL`.

Wynik powinien zawierac:

- `check_name`,
- `issue_count`.

Raport ma zawierac:

1. liczbe zamowien bez klienta,
2. liczbe pozycji zamowien bez produktu,
3. liczbe klientow bez emaila,
4. liczbe zamowien z niepoprawnym statusem.

## Zadanie 13

Napisz jednym zdaniem, czym rozni sie data quality check od reconciliation check.

