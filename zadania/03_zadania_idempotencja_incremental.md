# Zadania 03 - idempotencja, full refresh i incremental load

## Zadanie 1

Wyjasnij, czym jest idempotencja pipeline'u.

Podaj przyklad sytuacji, w ktorej brak idempotencji spowoduje blad w raporcie.

## Zadanie 2

Napisz, dlaczego ponizszy wzorzec moze byc niebezpieczny:

```sql
INSERT INTO mart.daily_revenue_by_country
SELECT ...
FROM core.orders_enriched;
```

## Zadanie 3

Napisz idempotentny schemat ladowania danych do `mart.daily_revenue_by_country` dla jednego dnia:

```text
2026-03-01
```

Uzyj wzorca:

```text
DELETE + INSERT
```

## Zadanie 4

Stworz constraint unikalny dla tabeli `mart.daily_revenue_by_country`, ktory pilnuje grainu:

```text
revenue_date + country
```

## Zadanie 5

Napisz przyklad `UPSERT` do tabeli `mart.daily_revenue_by_country`.

Zasady:

- jesli wiersz dla `revenue_date + country` nie istnieje, ma zostac dodany,
- jesli istnieje, ma zostac zaktualizowany `orders_count`, `paid_orders_count`, `cancelled_orders_count`, `total_revenue`.

## Zadanie 6

Wyjasnij roznice miedzy:

- `full refresh`,
- `incremental load`.

Podaj po jednym przypadku, kiedy dane podejscie ma sens.

## Zadanie 7

Napisz query, ktore pobiera z `raw.orders_raw` tylko rekordy zaladowane po:

```text
2026-03-01 00:00:00
```

Uzyj kolumny `loaded_at`.

## Zadanie 8

Wyjasnij roznice miedzy:

- `order_date`,
- `loaded_at`.

Podaj przyklad, kiedy te daty moga byc rozne.

## Zadanie 9

Napisz warunek `WHERE`, ktory przetwarza dane z ostatnich 3 dni na podstawie `order_date`.

To jest przyklad prostego `lookback window`.

## Zadanie 10

Zaprojektuj kolumny techniczne, ktore dodalbys do tabeli raw przy ladowaniu plikow.

Uwzglednij minimum:

- `loaded_at`,
- `batch_id`,
- `source_file`.

