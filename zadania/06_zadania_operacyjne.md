# Zadania 06 - orchestration, monitoring, lineage, batch i partycjonowanie

## Zadanie 1

Napisz kolejnosc uruchamiania pipeline'u:

```text
raw -> staging -> core -> mart -> data quality
```

Dla kazdego kroku napisz jedno zdanie, za co odpowiada.

## Zadanie 2

Napisz przykladowy run summary dla pipeline'u ladowania tabeli:

```text
mart.daily_revenue_by_country
```

Powinien zawierac:

- status,
- processing_date,
- target_table,
- rows_written,
- started_at,
- finished_at.

## Zadanie 3

Narysuj lineage tekstowo dla tabeli:

```text
mart.daily_revenue_by_country
```

Format:

```text
raw -> staging -> core -> mart
```

## Zadanie 4

Wyjasnij roznice miedzy batch i streaming.

Podaj po dwa przyklady.

## Zadanie 5

Podaj przyklad tabeli, ktora warto przetwarzac batchowo.

Wyjasnij dlaczego.

## Zadanie 6

Podaj przyklad danych, ktore moga wymagac streamingu.

Wyjasnij dlaczego batch moglby byc za wolny.

## Zadanie 7

Wyjasnij, po co partycjonuje sie duze tabele.

Uzyj pojecia `partition pruning`.

## Zadanie 8

Stworz tabele partycjonowana:

```text
core.orders_partitioned
```

Kolumny:

- `order_id INT`,
- `customer_id INT`,
- `order_date DATE`,
- `status VARCHAR(30)`,
- `total_amount NUMERIC(10, 2)`.

Partycjonuj po `order_date` przez `RANGE`.

## Zadanie 9

Stworz trzy partycje miesieczne:

- styczen 2026,
- luty 2026,
- marzec 2026.

## Zadanie 10

Wstaw kilka rekordow do `core.orders_partitioned`.

Dodaj minimum:

- jedno zamowienie ze stycznia,
- jedno z lutego,
- jedno z marca.

## Zadanie 11

Napisz query z `EXPLAIN`, ktore pobiera tylko zamowienia z marca 2026.

Warunek powinien pomagac w `partition pruning`.

## Zadanie 12

Napisz przyklad gorszego filtra, ktory moze utrudnic pruning, bo naklada funkcje na kolumne partycjonujaca.

## Zadanie 13

Wyjasnij roznice miedzy partycjonowaniem a indeksem.

## Zadanie 14

Wyjasnij, czym jest `over-partitioning`.

Podaj przyklad.

