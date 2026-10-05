# Zadania 05 - CDC, SCD i historia danych

## Zadanie 1

Wyjasnij, czym jest CDC.

Podaj po jednym przykladzie zmiany typu:

- `INSERT`,
- `UPDATE`,
- `DELETE`.

## Zadanie 2

Wyjasnij roznice miedzy:

- SCD Type 0,
- SCD Type 1,
- SCD Type 2.

## Zadanie 3

Stworz przykladowa tabele:

```text
core.dim_customer_history
```

Kolumny:

- `customer_history_key`,
- `customer_id`,
- `customer_name`,
- `country`,
- `valid_from`,
- `valid_to`,
- `is_current`.

## Zadanie 4

Dodaj dwa rekordy historyczne dla jednego klienta:

- pierwszy z krajem `PL`,
- drugi z krajem `DE`,
- tylko drugi ma byc aktualny.

## Zadanie 5

Napisz query, ktore zwroci tylko aktualna wersje klienta.

## Zadanie 6

Napisz query, ktore zwroci wersje klienta aktywna dla daty:

```text
2026-03-15
```

## Zadanie 7

Stworz prosta tabele faktow:

```text
core.fact_customer_orders_demo
```

Kolumny:

- `order_id`,
- `customer_id`,
- `order_date`,
- `net_value`.

Dodaj dwa zamowienia tego samego klienta:

- jedno przed zmiana kraju,
- jedno po zmianie kraju.

## Zadanie 8

Napisz query, ktore laczy `core.fact_customer_orders_demo` z `core.dim_customer_history`.

Zasady:

- join ma uzyc `customer_id`,
- join ma dobrac wersje klienta aktywna w dniu zamowienia,
- uzyj `valid_from` i `valid_to`.

## Zadanie 9

Napisz, dlaczego join po samym `customer_id` jest bledny przy SCD Type 2.

## Zadanie 10

Napisz przyklad soft delete w tabeli klientow.

Wystarczy pokazac, jakie kolumny bys dodal:

- `is_deleted`,
- `deleted_at`.

## Zadanie 11

Dla ponizszych zmian zdecyduj, czy bardziej pasuje SCD Type 1 czy SCD Type 2:

1. poprawka literowki w nazwisku klienta,
2. zmiana kraju klienta,
3. zmiana segmentu klienta z `standard` na `vip`,
4. poprawka blednego emaila,
5. zmiana kategorii produktu, ktora ma wplyw na raporty historyczne.

## Zadanie 12

Napisz jednym zdaniem, kiedy wystarczy SCD Type 1, a kiedy potrzebujemy SCD Type 2.

