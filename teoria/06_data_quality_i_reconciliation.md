# 06 - Data quality i reconciliation

## Co to jest data quality?

`Data quality` oznacza jakosc danych.

Nie wystarczy, ze query sie wykonuje. Dane musza byc:

- kompletne,
- unikalne tam, gdzie powinny byc unikalne,
- poprawne typami,
- spojne miedzy tabelami,
- zgodne z oczekiwanymi wartosciami,
- aktualne.

## Przyklady testow jakosci danych

### Brak NULL-i

```sql
SELECT *
FROM staging.stg_orders
WHERE order_id IS NULL;
```

### Unikalnosc klucza

```sql
SELECT
    order_id,
    COUNT(*) AS rows_count
FROM staging.stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

### Accepted values

```sql
SELECT DISTINCT status
FROM staging.stg_orders
WHERE status NOT IN ('paid', 'pending', 'cancelled');
```

### Range check

```sql
SELECT *
FROM staging.stg_orders
WHERE total_amount < 0;
```

## Co to jest reconciliation?

`Reconciliation` to porownanie danych miedzy warstwami albo systemami.

Przyklad:

```text
czy suma sprzedazy w staging zgadza sie z suma sprzedazy w mart?
```

Query:

```sql
SELECT
    'staging' AS source_name,
    SUM(total_amount) AS total_revenue
FROM staging.stg_orders
WHERE status = 'paid'

UNION ALL

SELECT
    'mart' AS source_name,
    SUM(total_revenue) AS total_revenue
FROM mart.daily_revenue_by_country;
```

## Dlaczego to wazne?

W pracy data engineera blad czesto nie wyglada jak blad SQL.

Query dziala, tabela istnieje, dashboard sie laduje, ale liczby sa zle.

Data quality pomaga wykryc:

- duplikaty,
- braki,
- zle statusy,
- zerwane relacje,
- niespojne sumy.

## Najwazniejsze

Dobry pipeline powinien nie tylko tworzyc dane.

Powinien tez umiec pokazac, ze dane sa poprawne.
