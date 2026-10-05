# 08 - Orchestration, monitoring i lineage

## Wstep dla osoby po podstawach SQL

Kiedy uczysz sie SQL, recznie odpalasz jedno zapytanie po drugim.

W pracy data engineera pipeline sklada sie z wielu krokow:

```text
zaladuj raw -> zbuduj staging -> zbuduj core -> zbuduj mart -> sprawdz jakosc
```

Te kroki musza uruchamiac sie w dobrej kolejnosci, a zespol musi wiedziec, czy pipeline sie udal, ile wierszy przetworzyl i z jakich tabel powstal wynik.

Ta lekcja jest o organizacji pracy pipeline'u: orkiestracji, monitoringu i lineage, czyli sledzeniu skad przyszly dane i dokad poszly.

## Co to jest orchestration?

`Orchestration` to zarzadzanie kolejnoscia uruchamiania zadan.

Przyklad:

```text
1. pobierz raw data
2. zbuduj staging
3. zbuduj core
4. zbuduj mart
5. sprawdz data quality
6. odswiez dashboard
```

Pipeline ma zaleznosci. Nie mozna zbudowac mart, zanim nie powstanie staging.

## Co robi orchestrator?

Orchestrator, np. Airflow, dba o:

- kolejnosc zadan,
- harmonogram,
- retry po bledzie,
- logi,
- statusy,
- zaleznosci.

## Monitoring

Monitoring odpowiada na pytanie:

```text
czy pipeline dziala i czy dane wygladaja sensownie?
```

Przyklady metryk:

- czy job sie zakonczyl sukcesem,
- ile wierszy zaladowano,
- kiedy pipeline ostatnio dzialal,
- ile trwalo przetwarzanie,
- czy liczba wierszy nagle nie spadla do zera.

## Lineage

`Lineage` oznacza pochodzenie danych.

Odpowiada na pytania:

- z jakich tabel powstala ta tabela?
- ktory raport korzysta z tej tabeli?
- co sie zepsuje, jezeli zmienimy kolumne?

Przyklad:

```text
raw.orders_raw
-> staging.stg_orders
-> core.orders_enriched
-> mart.daily_revenue_by_country
```

## Run summary

Na koncu pipeline'u warto zapisac albo wypisac podsumowanie:

- status,
- processing_date,
- target_table,
- rows_written,
- started_at,
- finished_at.

## Najwazniejsze

Dobry data engineer nie mysli tylko:

```text
czy query dziala?
```

Mysli tez:

```text
czy pipeline da sie uruchamiac codziennie, monitorowac i debugowac?
```
