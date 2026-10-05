# 03 - Warstwy danych: raw, staging, core, mart oraz bronze/silver/gold

## Po co sa warstwy danych?

Warstwy danych pomagaja oddzielic odpowiedzialnosci.

Bez warstw jedna tabela moze byc jednoczesnie:

- surowym importem,
- miejscem czyszczenia danych,
- miejscem logiki biznesowej,
- zrodlem dashboardu,
- miejscem testow i poprawek.

To szybko robi balagan.

Po ludzku:

```text
Warstwa danych mowi, na jakim etapie przetworzenia sa dane i do czego wolno ich uzywac.
```

Przyklad:

```text
raw.orders_raw
```

to nie jest to samo co:

```text
mart.daily_sales_summary
```

Pierwsza tabela odpowiada na pytanie:

```text
co przyszlo ze zrodla?
```

Druga odpowiada na pytanie:

```text
ile sprzedalismy danego dnia?
```

## Problem bez warstw

Wyobraz sobie, ze firma ma jedna tabele:

```text
orders
```

I wszyscy z niej korzystaja:

- aplikacja zapisuje zamowienia,
- data engineer poprawia statusy,
- analityk liczy revenue,
- dashboard czyta wyniki,
- ktos recznie poprawia bledy.

Po czasie pojawiaja sie pytania:

- czy ta tabela jest surowa czy oczyszczona?
- czy statusy sa juz wystandaryzowane?
- czy duplikaty zostaly usuniete?
- czy revenue liczy tylko oplacone zamowienia?
- czy dashboard moze z niej czytac?

Warstwy rozwiazuja ten problem przez podzial odpowiedzialnosci.

## Typowy przeplyw danych

W tej iteracji uzywamy takiego sposobu myslenia:

```text
raw -> staging -> core -> mart
```

Mozna to rozumiec tak:

```text
dane surowe -> dane technicznie wyczyszczone -> dane biznesowo zaufane -> dane raportowe
```

## Raw

`raw` to dane surowe.

Po ludzku:

```text
raw to prawda o tym, co przyszlo ze zrodla
```

Cechy raw:

- dane sa blisko zrodla,
- zmiany sa minimalne,
- moga byc brzydkie typy danych,
- moga byc duplikaty,
- moga byc dziwne statusy,
- moga byc puste wartosci,
- raw przydaje sie do audytu i ponownego przetworzenia.

Przyklad:

```text
raw.orders_raw
```

moze miec dane:

```text
order_id | customer_id | order_date  | status     | total_amount
1001     | 1           | 2026/01/05  | PAID       | 100.00
1002     | 2           | 05-01-2026  | Cancelled  | 50.00
1003     | 3           | brak        | paid       | 80.00
```

W raw nie musimy jeszcze wszystkiego naprawiac.

Raw ma zachowac dane tak, zeby mozna bylo sprawdzic:

```text
co dokladnie przyszlo ze zrodla?
```

## Co zwykle dodaje sie do raw?

W realnych projektach do raw czesto dodaje sie kolumny techniczne:

- `loaded_at` - kiedy rekord zostal zaladowany,
- `source_file_name` - z jakiego pliku przyszedl,
- `source_system` - z jakiego systemu przyszedl,
- `batch_id` - w ktorym uruchomieniu pipeline'u przyszedl.

Przyklad:

```text
raw.orders_raw
order_id, customer_id, order_date, status, loaded_at, source_file_name
```

Te kolumny pomagaja debugowac pipeline.

## Staging

`staging` to warstwa technicznego czyszczenia.

Po ludzku:

```text
staging robi dane czytelne i poprawne technicznie
```

Typowe operacje w staging:

- zmiana typow danych,
- zmiana nazw kolumn,
- przyciecie spacji przez `TRIM`,
- standaryzacja wielkosci liter przez `LOWER` albo `UPPER`,
- usuniecie oczywistych duplikatow,
- zamiana pustego tekstu na `NULL`,
- przygotowanie grainu.

Przyklad:

```text
staging.stg_orders
```

moze zmienic:

```text
'PAID', 'Paid', 'paid'
```

na:

```text
'paid'
```

Moze tez zmienic tekst:

```text
'2026/01/05'
```

na typ:

```text
DATE
```

## Staging nie powinien robic wszystkiego

W staging zwykle nie chcemy jeszcze budowac koncowych raportow.

Staging odpowiada glownie za pytanie:

```text
czy dane sa technicznie gotowe do dalszej pracy?
```

Przyklad staging:

```sql
CREATE TABLE staging.stg_orders AS
SELECT
    CAST(order_id AS INT) AS order_id,
    CAST(customer_id AS INT) AS customer_id,
    CAST(order_date AS DATE) AS order_date,
    LOWER(TRIM(status)) AS status,
    CAST(total_amount AS NUMERIC(10, 2)) AS total_amount
FROM raw.orders_raw;
```

## Core

`core` to warstwa danych zaufanych biznesowo.

Po ludzku:

```text
core to miejsce, gdzie firma ma wspolna wersje podstawowych encji
```

Core odpowiada na pytania:

- czym jest poprawne zamowienie?
- jaki status uznajemy za oplacony?
- jak laczymy klienta z zamowieniem?
- czy mamy jedna wersje klienta?
- czy klucze sa spojne?

Przyklady tabel core:

```text
core.customers
core.products
core.orders
core.payments
core.order_items
```

W core mozemy juz miec logike biznesowa.

Przyklad:

```text
is_paid = true, jezeli payment_status = 'paid'
```

albo:

```text
order_value_net = gross_value - discount_value
```

## Core vs staging

Staging:

```text
poprawia dane technicznie
```

Core:

```text
nadaje danym sens biznesowy
```

Przyklad:

W staging robimy:

```text
status -> lower(status)
```

W core robimy:

```text
is_successful_order = status = 'completed' AND payment_status = 'paid'
```

## Mart

`mart` to warstwa gotowa do raportowania.

Po ludzku:

```text
mart to tabela przygotowana pod konkretna analize albo dashboard
```

Cechy mart:

- ma jasny grain,
- czesto jest zagregowany,
- zawiera KPI,
- jest wygodny dla analityka,
- moze byc denormalizowany,
- nie powinien byc miejscem recznego czyszczenia danych.

Przyklady:

```text
mart.daily_revenue_by_country
mart.monthly_product_sales
mart.customer_lifetime_value
mart.sales_channel_performance
```

Przyklad grainu:

```text
mart.daily_revenue_by_country
```

Jeden wiersz oznacza:

```text
jeden dzien + jeden kraj
```

## Przyklad martu

```sql
CREATE TABLE mart.daily_revenue_by_country AS
SELECT
    order_date,
    country,
    COUNT(DISTINCT order_id) AS orders_count,
    SUM(order_value_net) AS net_revenue
FROM core.orders_enriched
GROUP BY
    order_date,
    country;
```

Taka tabela jest wygodna dla dashboardu, bo dashboard nie musi za kazdym razem laczyc 5 tabel.

## Raw/staging/core/mart na jednym przykladzie

Zrodlo:

```text
plik orders.csv
```

Raw:

```text
raw.orders_raw
```

Trzyma dane blisko pliku.

Staging:

```text
staging.stg_orders
```

Poprawia typy, nazwy i statusy.

Core:

```text
core.orders_enriched
```

Dodaje logike biznesowa: klient, platnosc, revenue, flaga `is_paid`.

Mart:

```text
mart.daily_sales_summary
```

Daje gotowy wynik pod dashboard.

## Bronze, Silver, Gold

`Bronze`, `Silver`, `Gold` to podobny sposob myslenia, czesto uzywany w lakehouse.

Mapowanie:

| Medallion | Klasyczne warstwy | Znaczenie |
|---|---|---|
| Bronze | raw | dane surowe |
| Silver | staging/core | dane oczyszczone i ujednolicone |
| Gold | mart | dane gotowe do analityki |

Przyklad:

```text
bronze.orders
-> silver.orders_enriched
-> gold.daily_sales_summary
```

## Architektura medalionowa

Architektura medalionowa to sposob organizowania danych w warstwy:

```text
Bronze -> Silver -> Gold
```

Nazwa pochodzi od medali:

- `Bronze` - dane najmniej przetworzone,
- `Silver` - dane oczyszczone i ujednolicone,
- `Gold` - dane najlepszej jakosci, gotowe do raportow i decyzji.

Po ludzku:

```text
Architektura medalionowa pokazuje droge danych od surowego zrodla do gotowego produktu analitycznego.
```

To nie jest tylko nazewnictwo tabel. To jest sposob myslenia o jakosci danych.

## Bronze w architekturze medalionowej

`Bronze` to pierwsza warstwa po pobraniu danych ze zrodla.

Bronze odpowiada na pytanie:

```text
Co przyszlo ze zrodla?
```

Przyklady zrodel:

- plik CSV,
- API,
- tabela z systemu OLTP,
- eksport z systemu platnosci,
- logi aplikacji,
- eventy z kolejki.

Przyklady tabel Bronze:

```text
bronze.customers
bronze.orders
bronze.order_items
bronze.payments
bronze.products
```

Cechy Bronze:

- dane sa blisko oryginalnego zrodla,
- nie robimy agregacji,
- nie liczymy finalnych KPI,
- zachowujemy oryginalne statusy,
- mozemy miec duplikaty,
- mozemy miec braki,
- mozemy miec tekstowe typy danych,
- czesto dodajemy kolumny techniczne, np. `loaded_at`.

Przyklad:

```text
bronze.orders
order_id | customer_id | order_timestamp     | status     | source_file
1001     | 1           | 2026-01-05 10:00:00 | PAID       | orders_2026_01.csv
1002     | 2           | 2026-01-06 11:00:00 | Cancelled  | orders_2026_01.csv
```

Bronze nie musi byc idealne. Bronze ma byc wierne temu, co przyszlo.

## Silver w architekturze medalionowej

`Silver` to warstwa oczyszczona i ujednolicona.

Silver odpowiada na pytanie:

```text
Jak wygladaja dane po podstawowym czyszczeniu i uporzadkowaniu?
```

W Silver zwykle robimy:

- poprawne typy danych,
- standaryzacje tekstu,
- usuwanie technicznych duplikatow,
- laczenie danych z kilku zrodel,
- sprawdzenie kluczy,
- podstawowe reguly biznesowe,
- pola pomocnicze do dalszej analizy.

Przyklady tabel Silver:

```text
silver.customers_clean
silver.products_clean
silver.orders_enriched
silver.order_items_enriched
silver.payments_clean
```

Przyklad zmiany Bronze -> Silver:

```text
Bronze:
status = 'PAID', 'Paid', 'paid'

Silver:
payment_status = 'paid'
```

Albo:

```text
Bronze:
discount_percent = 10

Silver:
gross_value = quantity * unit_price
discount_value = gross_value * discount_percent / 100
net_value = gross_value - discount_value
```

Silver jest czesto najwazniejsza dla data engineera, bo tutaj powstaje porzadek, z ktorego korzystaja kolejne warstwy.

## Gold w architekturze medalionowej

`Gold` to warstwa gotowa dla odbiorcow biznesowych.

Gold odpowiada na pytanie:

```text
Jakie dane dajemy analitykom, dashboardom albo managerom?
```

W Gold zwykle mamy:

- agregaty,
- KPI,
- rankingi,
- tabele pod konkretne raporty,
- tabele pod dashboardy,
- dane z jasnym grainem,
- metryki policzone wedlug jednej definicji.

Przyklady tabel Gold:

```text
gold.daily_sales_summary
gold.customer_analytics
gold.product_performance_monthly
gold.sales_channel_performance
```

Przyklad:

```text
gold.daily_sales_summary
```

Jeden wiersz moze oznaczac:

```text
jeden dzien + jeden kraj + jeden kanal sprzedazy
```

Kolumny:

```text
sales_date
country
sales_channel
orders_count
paid_orders_count
net_revenue
cancelled_orders_count
```

Gold nie powinien byc miejscem brudnego czyszczenia danych. Gold powinien korzystac z Silver.

## Przyklad architektury medalionowej dla e-commerce

```text
Bronze:
bronze.customers
bronze.orders
bronze.order_items
bronze.payments
bronze.products

Silver:
silver.customers_clean
silver.orders_enriched
silver.order_items_enriched
silver.products_clean

Gold:
gold.daily_sales_summary
gold.customer_analytics
gold.product_performance_monthly
```

Przeplyw:

```text
bronze.orders
bronze.payments
        |
        v
silver.orders_enriched
        |
        v
gold.daily_sales_summary
```

## Dlaczego architektura medalionowa jest przydatna?

Pomaga:

- uporzadkowac pipeline,
- debugowac bledy warstwa po warstwie,
- odtworzyc dane od Bronze do Gold,
- oddzielic dane surowe od raportowych,
- uniknac liczenia metryk w wielu miejscach,
- pokazac jakosc danych na kazdym etapie.

Przyklad debugowania:

```text
Dashboard pokazuje zly revenue.
Sprawdzamy Gold: czy agregacja jest dobra?
Sprawdzamy Silver: czy net_value jest dobrze policzone?
Sprawdzamy Bronze: czy dane ze zrodla przyszly poprawnie?
```

Bez warstw wszystko miesza sie w jednej tabeli i trudniej znalezc blad.

## Czego pilnowac w architekturze medalionowej?

Pilnuj:

- zeby Bronze nie bylo raportem,
- zeby Silver mialo jasne reguly czyszczenia,
- zeby Gold mial jasny grain,
- zeby dashboardy czytaly z Gold, a nie z Bronze,
- zeby metryki biznesowe byly liczone w jednym miejscu,
- zeby nazwy tabel mowily, do czego tabela sluzy.

Najprostsza zasada:

```text
Bronze przechowuje.
Silver porzadkuje.
Gold odpowiada na pytania biznesowe.
```

## Czy bronze/silver/gold i raw/staging/core/mart to zawsze to samo?

Nie zawsze.

Rozne firmy moga miec rozne nazwy:

- `raw`, `clean`, `analytics`,
- `landing`, `staging`, `presentation`,
- `bronze`, `silver`, `gold`,
- `source`, `core`, `mart`.

Najwazniejsza jest nie nazwa, tylko odpowiedzialnosc warstwy.

Pytanie, ktore trzeba zadac:

```text
do czego sluzy ta tabela?
```

## Czego nie robic?

Nie warto:

- budowac dashboardu bezposrednio na raw,
- czyscic danych recznie w mart,
- trzymac kilku wersji tej samej metryki w roznych miejscach,
- mieszac danych surowych z raportowymi,
- nazywac tabeli `final_final_v2`.

## Najwazniejsze

Warstwy nie sa tylko nazwami schematow.

Warstwy odpowiadaja na pytania:

```text
Jak bardzo dane sa przetworzone?
Kto moze ich uzywac?
Do czego ta tabela sluzy?
Czy moge ufac tej metryce?
Czy moge odtworzyc wynik od poczatku?
```

## Mini sciaga

| Warstwa | Co robi? | Przyklad |
|---|---|---|
| raw | przechowuje dane surowe | `raw.orders_raw` |
| staging | czysci technicznie | `staging.stg_orders` |
| core | buduje zaufane encje biznesowe | `core.orders_enriched` |
| mart | przygotowuje raporty i KPI | `mart.daily_sales_summary` |
| bronze | dane surowe | `bronze.orders` |
| silver | dane oczyszczone | `silver.orders_enriched` |
| gold | dane raportowe | `gold.daily_sales_summary` |

## Co musisz umiec po tej lekcji?

Powinienes umiec:

- wyjasnic roznice miedzy raw, staging, core i mart,
- powiedziec po co sa warstwy danych,
- wyjasnic architekture medalionowa Bronze/Silver/Gold,
- powiedziec co powinno trafiac do Bronze, Silver i Gold,
- podac przyklad transformacji raw -> staging,
- podac przyklad transformacji staging/core -> mart,
- wyjasnic mapowanie bronze/silver/gold,
- wskazac, z ktorej warstwy powinien korzystac dashboard.
