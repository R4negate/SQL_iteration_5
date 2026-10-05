# 04 - Idempotencja i incremental load

## Po co ta lekcja?

W poprzednich lekcjach pisalismy zapytania i budowalismy warstwy danych.

Teraz dochodzi bardzo wazne pytanie produkcyjne:

```text
Co sie stanie, jezeli pipeline uruchomi sie drugi raz?
```

W prawdziwej pracy data engineera pipeline'y:

- czasem sie wywalaja,
- czasem trzeba je odpalic ponownie,
- czasem dostaja spoznione dane,
- czasem przetwarzaja ten sam plik drugi raz,
- czasem musza poprawic dane historyczne.

Dlatego zapytanie, ktore dziala raz, to za malo.

Dobry pipeline powinien byc:

- powtarzalny,
- odporny na duplikaty,
- mozliwy do debugowania,
- bezpieczny przy ponownym uruchomieniu.

## Co to jest idempotencja?

Proces jest idempotentny, jezeli mozna uruchomic go wiele razy i koncowy wynik pozostaje poprawny.

Po ludzku:

```text
Moge odpalic ten sam proces drugi, trzeci i czwarty raz, a dane koncowe nadal sa poprawne.
```

Przyklad:

```text
uruchamiam pipeline dla 2026-01-01 raz -> wynik poprawny
uruchamiam ten sam pipeline drugi raz -> wynik nadal poprawny, bez duplikatow
```

To jest bardzo wazne, bo pipeline'y produkcyjne czesto sa uruchamiane ponownie po bledzie.

## Przyklad nieidempotentny

Wyobraz sobie tabele:

```text
mart.daily_revenue
```

I taki kod:

```sql
INSERT INTO mart.daily_revenue (
    revenue_date,
    country,
    total_revenue
)
SELECT
    order_date,
    country,
    SUM(total_amount) AS total_revenue
FROM core.orders
GROUP BY
    order_date,
    country;
```

Problem:

```text
Za kazdym uruchomieniem dopisujemy te same wyniki jeszcze raz.
```

Jesli uruchomisz pipeline dwa razy, mozesz dostac:

```text
2026-01-01 | PL | 1000
2026-01-01 | PL | 1000
```

Wynik raportu moze potem pokazac `2000`, mimo ze prawdziwy revenue to `1000`.

## Dlaczego zwykly INSERT SELECT bywa niebezpieczny?

`INSERT SELECT` sam z siebie nie wie, czy dane juz byly wstawione.

To jest tylko polecenie:

```text
dopisz wynik zapytania do tabeli
```

Jesli chcesz bezpieczenstwa, musisz dodac logike:

- usun i wstaw ponownie dany zakres,
- uzyj `ON CONFLICT`,
- uzyj klucza unikalnego,
- sprawdz watermark,
- kontroluj `batch_id`,
- zapisuj audit columns.

## Wzorzec 1: delete + insert

Bardzo prosty wzorzec idempotentny:

```text
usun obszar, ktory przetwarzasz
wstaw go od nowa
```

Przyklad dla jednego dnia:

```sql
DELETE FROM mart.daily_revenue
WHERE revenue_date = DATE '2026-01-01';

INSERT INTO mart.daily_revenue (
    revenue_date,
    country,
    total_revenue
)
SELECT
    order_date AS revenue_date,
    country,
    SUM(total_amount) AS total_revenue
FROM core.orders
WHERE order_date = DATE '2026-01-01'
GROUP BY
    order_date,
    country;
```

Jesli uruchomisz ten kod drugi raz:

1. najpierw usunie wynik dla `2026-01-01`,
2. potem wstawi go od nowa,
3. nie powstana duplikaty.

Ten wzorzec jest prosty i bardzo dobry do nauki.

## Wzorzec 2: upsert

Drugi wzorzec to `UPSERT`, czyli:

```text
insert albo update
```

W PostgreSQL robimy to przez:

```sql
ON CONFLICT (...) DO UPDATE
```

Przyklad:

```sql
INSERT INTO mart.daily_revenue (
    revenue_date,
    country,
    total_revenue
)
SELECT
    order_date AS revenue_date,
    country,
    SUM(total_amount) AS total_revenue
FROM core.orders
WHERE order_date = DATE '2026-01-01'
GROUP BY
    order_date,
    country
ON CONFLICT (revenue_date, country) DO UPDATE SET
    total_revenue = EXCLUDED.total_revenue;
```

Zeby to dzialalo, tabela musi miec unikalnosc:

```sql
ALTER TABLE mart.daily_revenue
ADD CONSTRAINT uq_daily_revenue
UNIQUE (revenue_date, country);
```

Po ludzku:

```text
Jesli taki dzien i kraj juz istnieje, nie dopisuj duplikatu, tylko zaktualizuj wynik.
```

## Wzorzec 3: full refresh

`Full refresh` oznacza:

```text
budujemy cala tabele od zera
```

Przyklad:

```sql
DROP TABLE IF EXISTS mart.daily_revenue;

CREATE TABLE mart.daily_revenue AS
SELECT
    order_date AS revenue_date,
    country,
    SUM(total_amount) AS total_revenue
FROM core.orders
GROUP BY
    order_date,
    country;
```

Zalety:

- proste,
- latwe do zrozumienia,
- mniejsze ryzyko duplikatow,
- dobre dla malych danych.

Wady:

- przy duzych danych moze byc wolne,
- przelicza wszystko, nawet gdy zmienil sie tylko jeden dzien,
- moze mocno obciazac baze.

## Incremental load

`Incremental load` oznacza:

```text
ladujemy tylko nowe albo zmienione dane
```

Zamiast przeladowywac wszystko od poczatku.

Przyklad:

```sql
WHERE updated_at > ostatnio_przetworzony_czas
```

Albo:

```sql
WHERE order_date = processing_date
```

Po ludzku:

```text
Nie przerabiam calej historii, tylko ten fragment, ktory mogl sie zmienic.
```

## Full refresh vs incremental

| Tryb | Znaczenie | Kiedy dobry? |
|---|---|---|
| full refresh | budujemy cala tabele od zera | male dane, prosta logika, przebudowa modelu |
| incremental | przetwarzamy tylko nowe/zmienione dane | duze dane, codzienne pipeline'y, oszczednosc czasu |

Full refresh jest prostszy, ale moze byc wolny.

Incremental jest szybszy, ale wymaga lepszej logiki.

## Watermark

`Watermark` to informacja:

```text
do ktorego momentu dane zostaly juz przetworzone
```

Przyklad:

```text
last_loaded_at = 2026-01-10 12:00:00
```

Wtedy kolejny run moze pobrac:

```sql
SELECT *
FROM raw.orders
WHERE loaded_at > TIMESTAMP '2026-01-10 12:00:00';
```

Watermark pomaga robic incremental load.

## Problem ze spoznionymi danymi

Incremental load ma pulapke.

Co jesli dzisiaj przyjdzie spoznione zamowienie z wczoraj?

Przyklad:

```text
Pipeline dla 2026-01-01 juz sie wykonal.
Potem system doslal brakujace zamowienie z 2026-01-01.
```

Jesli pipeline zawsze bierze tylko dzisiejsza date, moze pominac spoznione dane.

Rozwiazanie:

```text
przetwarzaj okno kilku ostatnich dni
```

Przyklad:

```sql
WHERE order_date >= CURRENT_DATE - INTERVAL '3 days'
```

To nazywa sie czasem:

```text
lookback window
```

## Incremental po dacie biznesowej vs technicznej

Mozesz filtrowac po dacie biznesowej:

```sql
WHERE order_date = DATE '2026-01-01'
```

Albo po dacie technicznej:

```sql
WHERE loaded_at > last_loaded_at
```

Roznica:

- `order_date` mowi, kiedy wydarzylo sie zamowienie,
- `loaded_at` mowi, kiedy rekord trafil do pipeline'u.

W data engineeringu to sa dwie rozne rzeczy.

Przyklad:

```text
Zamowienie bylo 1 stycznia, ale do systemu analitycznego trafilo 3 stycznia.
```

Wtedy:

```text
order_date = 2026-01-01
loaded_at = 2026-01-03
```

## Audit columns

W pipeline'ach czesto dodaje sie kolumny techniczne:

- `loaded_at`,
- `updated_at`,
- `batch_id`,
- `source_system`,
- `source_file`.

One pomagaja odpowiedziec:

- kiedy rekord zostal zaladowany?
- z jakiego pliku pochodzi?
- ktory run pipeline'u go utworzyl?
- czy rekord przyszedl drugi raz?
- gdzie szukac bledu?

Przyklad tabeli raw:

```sql
CREATE TABLE raw.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_date TEXT,
    status TEXT,
    total_amount TEXT,
    loaded_at TIMESTAMP,
    batch_id TEXT,
    source_file TEXT
);
```

## Batch id

`batch_id` identyfikuje konkretne uruchomienie pipeline'u albo konkretny plik.

Przyklad:

```text
batch_id = orders_2026_01_01_run_001
```

Dzieki temu mozna sprawdzic:

```sql
SELECT
    batch_id,
    COUNT(*) AS rows_count
FROM raw.orders_raw
GROUP BY batch_id;
```

To pomaga kontrolowac, ile rekordow przyszlo w danym uruchomieniu.

## Najprostszy bezpieczny pipeline dzienny

Przyklad logiki:

```text
1. Ustal processing_date.
2. Usun z mart dane dla processing_date.
3. Przelicz wynik z core dla processing_date.
4. Wstaw wynik do mart.
5. Zapisz loaded_at albo batch_id.
```

SQL:

```sql
DELETE FROM mart.daily_sales
WHERE sales_date = DATE '2026-01-01';

INSERT INTO mart.daily_sales (
    sales_date,
    country,
    orders_count,
    total_revenue,
    loaded_at
)
SELECT
    order_date AS sales_date,
    country,
    COUNT(order_id) AS orders_count,
    SUM(total_amount) AS total_revenue,
    CURRENT_TIMESTAMP AS loaded_at
FROM core.orders
WHERE order_date = DATE '2026-01-01'
GROUP BY
    order_date,
    country;
```

To jest idempotentne dla jednego dnia.

## Najwazniejsze

Dobry pipeline powinien byc:

- powtarzalny,
- bezpieczny przy ponownym uruchomieniu,
- mozliwy do sprawdzenia,
- odporny na duplikaty,
- jasny co do zakresu danych, ktory przetwarza.

## Mini sciaga

| Pojecie | Znaczenie |
|---|---|
| Idempotencja | ponowne uruchomienie nie psuje wyniku |
| Full refresh | przeliczenie calej tabeli od zera |
| Incremental load | przetwarzanie tylko nowych lub zmienionych danych |
| Watermark | informacja, do ktorego momentu dane przetworzono |
| Lookback window | ponowne przetwarzanie ostatnich kilku dni |
| Audit columns | techniczne kolumny do debugowania pipeline'u |
| Batch id | identyfikator konkretnego uruchomienia lub paczki danych |

## Co musisz umiec po tej lekcji?

Powinienes umiec:

- wyjasnic idempotencje,
- pokazac przyklad nieidempotentnego `INSERT SELECT`,
- napisac prosty wzorzec `DELETE + INSERT`,
- wyjasnic full refresh i incremental load,
- powiedziec po co jest watermark,
- powiedziec po co sa `loaded_at`, `source_file` i `batch_id`,
- wyjasnic problem spoznionych danych.

