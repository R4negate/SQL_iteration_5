# SQL iteration 5 - modelowanie danych i architektura analityczna

Ta iteracja laczy SQL z praca data engineera.

Po poprzednich iteracjach umiesz juz:

- czytac dane przez `SELECT`,
- laczyc tabele przez `JOIN`,
- agregowac dane,
- pisac subquery, CTE i window functions,
- zmieniac dane przez DML,
- tworzyc tabele, constraints, indeksy i widoki.

Teraz uczymy sie, jak myslec o danych jako o systemie:

- skad dane przychodza,
- jak sa czyszczone,
- gdzie powstaje logika biznesowa,
- jak buduje sie tabele do raportowania,
- czym roznia sie tabele aplikacyjne od analitycznych.

## Kolejnosc

1. `teoria/01_etl_elt_i_architektura_danych.md`
2. `teoria/02_oltp_olap_normalizacja_denormalizacja.md`
3. `teoria/03_warstwy_raw_staging_core_mart_medallion.md`
4. `teoria/04_idempotencja_i_incremental_load.md`
5. `teoria/05_fakty_wymiary_star_schema.md`
6. `teoria/06_data_quality_i_reconciliation.md`
7. `teoria/07_cdc_scd_i_historia_danych.md`
8. `teoria/08_orchestration_monitoring_lineage.md`
9. `teoria/09_batch_streaming_partycjonowanie.md`
10. `zadania/01_zadania_modelowanie_i_warstwy.md`
11. `zadania/02_zadania_star_schema.md`
12. `zadania/03_zadania_idempotencja_incremental.md`
13. `zadania/04_zadania_data_quality.md`
14. `zadania/05_zadania_cdc_scd.md`
15. `zadania/06_zadania_operacyjne.md`
16. `projekt_koncowy/README.md`

## Schematy

W tej iteracji uzywamy kilku schematow:

- `course` - dane z poprzednich iteracji,
- `raw` - dane surowe,
- `staging` - dane oczyszczone technicznie,
- `core` - dane biznesowo ustandaryzowane,
- `mart` - dane gotowe do raportowania,
- `star` - model faktow i wymiarow.

## Start

Przed zadaniami uruchom skrypty z:

```text
zadania/DDL
```

Kolejnosc:

1. `00_create_schemas.sql`
2. `01_create_raw_tables.sql`
3. `02_insert_raw_data.sql`
4. `03_smoke_test.sql`

## Projekt koncowy

Po przejsciu teorii i zadan wykonaj projekt:

```text
projekt_koncowy
```

Projekt polega na zbudowaniu mini-platformy analitycznej commerce w PostgreSQL:

```text
raw -> bronze -> silver -> gold -> zapytania analityczne
```
