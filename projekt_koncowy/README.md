# Projekt koncowy: Commerce Analytics Mini Platform

## 1. Historia biznesowa

Pracujesz jako junior data engineer w firmie **EduCommerce**, ktora sprzedaje produkty cyfrowe dla osob uczacych sie analityki danych:

- kursy online,
- pakiety SQL,
- materialy PDF,
- szablony dashboardow,
- konsultacje i mentoring.

Firma ma juz sklep internetowy. Klienci skladaja zamowienia, zamowienia maja pozycje, produkty maja kategorie, a platnosci maja swoje statusy. Problem polega na tym, ze dane sa rozproszone po kilku tabelach operacyjnych i nie sa jeszcze przygotowane do analizy.

Zespol biznesowy chce odpowiadac na pytania:

- ile firma sprzedaje dziennie,
- ktore kraje generuja najwiekszy przychod,
- ktore kanaly sprzedazy dzialaja najlepiej,
- ktorzy klienci sa najcenniejsi,
- ktore produkty sprzedaja sie najlepiej miesiac po miesiacu,
- czy rabaty mocno obnizaja revenue,
- ile zamowien jest oplaconych, oczekujacych albo anulowanych.

Twoim zadaniem jest zbudowanie w PostgreSQL malej platformy analitycznej:

```text
raw -> bronze -> silver -> gold
```

## 3. Schematy do utworzenia

Utworz cztery schematy:

- `raw`,
- `bronze`,
- `silver`,
- `gold`.

Znaczenie schematow:

- `raw` - surowe dane, takie jak przyszly z systemu,
- `bronze` - techniczna kopia danych raw,
- `silver` - dane oczyszczone, ustandaryzowane i wzbogacone,
- `gold` - tabele koncowe pod analize.

## 4. Warstwa raw 

Kolumny:

| Kolumna | Typ danych | Ograniczenia | Opis |
|---|---:|---|---|
| `customer_id` | `INT` | `PRIMARY KEY` | Unikalny identyfikator klienta |
| `customer_name` | `VARCHAR(100)` | `NOT NULL` | Imie i nazwisko klienta |
| `email` | `VARCHAR(150)` | moze byc `NULL` | Email klienta |
| `country` | `VARCHAR(2)` | `NOT NULL` | Kod kraju, np. `PL`, `DE`, `FR` |
| `signup_date` | `DATE` | `NOT NULL` | Data rejestracji klienta |
| `acquisition_channel` | `VARCHAR(30)` | moze byc `NULL` | Kanal pozyskania, np. newsletter, paid ads, organic |

### Tabela `raw.products`

Kolumny:

| Kolumna | Typ danych | Ograniczenia | Opis |
|---|---:|---|---|
| `product_id` | `INT` | `PRIMARY KEY` | Unikalny identyfikator produktu |
| `product_name` | `VARCHAR(100)` | `NOT NULL` | Nazwa produktu |
| `category` | `VARCHAR(50)` | `NOT NULL` | Kategoria produktu |
| `base_price` | `NUMERIC(10, 2)` | `NOT NULL` | Cena bazowa produktu |

### Tabela `raw.orders`

Kolumny:

| Kolumna | Typ danych | Ograniczenia | Opis |
|---|---:|---|---|
| `order_id` | `INT` | `PRIMARY KEY` | Unikalny identyfikator zamowienia |
| `customer_id` | `INT` | `NOT NULL` | Identyfikator klienta |
| `order_timestamp` | `TIMESTAMP` | `NOT NULL` | Data i czas zlozenia zamowienia |
| `status` | `VARCHAR(30)` | `NOT NULL` | Status zamowienia, np. completed, pending, cancelled |
| `currency` | `VARCHAR(3)` | `NOT NULL` | Waluta, np. EUR |
| `sales_channel` | `VARCHAR(30)` | `NOT NULL` | Kanal sprzedazy, np. web albo mobile |

### Tabela `raw.order_items`

Kolumny:

| Kolumna | Typ danych | Ograniczenia | Opis |
|---|---:|---|---|
| `order_item_id` | `INT` | `PRIMARY KEY` | Unikalny identyfikator pozycji zamowienia |
| `order_id` | `INT` | `NOT NULL` | Identyfikator zamowienia |
| `product_id` | `INT` | `NOT NULL` | Identyfikator produktu |
| `quantity` | `INT` | `NOT NULL` | Liczba sztuk |
| `unit_price` | `NUMERIC(10, 2)` | `NOT NULL` | Cena jednostkowa w momencie zakupu |
| `discount_percent` | `NUMERIC(5, 2)` | `NOT NULL` | Rabat procentowy, np. `10.00` |

### Tabela `raw.payments`

Kolumny:

| Kolumna | Typ danych | Ograniczenia | Opis |
|---|---:|---|---|
| `payment_id` | `INT` | `PRIMARY KEY` | Unikalny identyfikator platnosci |
| `order_id` | `INT` | `NOT NULL` | Identyfikator zamowienia |
| `payment_status` | `VARCHAR(30)` | `NOT NULL` | Status platnosci, np. paid, pending, failed |
| `payment_method` | `VARCHAR(30)` | `NOT NULL` | Metoda platnosci, np. card, blik, paypal |
| `paid_at` | `TIMESTAMP` | moze byc `NULL` | Moment oplacenia zamowienia |

```text
Po stworzeniu tabel z warstwy raw załaduj do nich dane poprzez uruchomienie skryptu load_raw_data.sql z folderu sql 
```

## 5. Co masz zbudowac w warstwie bronze

Warstwa `bronze` ma byc kopia danych z `raw`.

Utworz tabele:

- `bronze.customers`,
- `bronze.products`,
- `bronze.orders`,
- `bronze.order_items`,
- `bronze.payments`.

## 6. Co masz zbudowac w warstwie silver

Warstwa `silver` ma przygotowac dane do dalszej analizy.

Utworz tabele:

- `silver.customers_clean`,
- `silver.products_clean`,
- `silver.orders_enriched`,
- `silver.order_items_enriched`.

### `silver.customers_clean`

Cel:

- oczyscic dane klientow,
- ustandaryzowac teksty.

Wynik powinien zawierac:

- `customer_id`,
- `customer_name`,
- `email`,
- `country`,
- `signup_date`,
- `acquisition_channel`.

Wskazowki:

- przytnij spacje z tekstow,
- email zapisz malymi literami,
- kraj zapisz wielkimi literami,
- kanal pozyskania zapisz malymi literami
- itp...

### `silver.products_clean`

Cel:

- oczyscic dane produktow,
- ujednolicic kategorie.

Wynik powinien zawierac:

- `product_id`,
- `product_name`,
- `category`,
- `base_price`.

Wskazowki:

- nazwe produktu przytnij ze spacji,
- kategorie zapisz malymi literami.
- itp...

### `silver.orders_enriched`

Cel:

- polaczyc zamowienia z platnosciami,
- dodac pola przydatne analitycznie.

Wynik powinien zawierac:

- `order_id`,
- `customer_id`,
- `order_date`,
- `order_timestamp`,
- `order_month`,
- `order_status`,
- `currency`,
- `sales_channel`,
- `payment_status`,
- `payment_method`,
- `is_paid`,
- `first_order_date`.

Wskazowki:

- `order_date` to data wyciagnieta z `order_timestamp`,
- `order_month` to pierwszy dzien miesiaca zamowienia,
- `order_status` zapisz malymi literami,
- `currency` zapisz wielkimi literami,
- `sales_channel` zapisz malymi literami,
- `is_paid` ma byc `TRUE`, jesli `payment_status = 'paid'`,
- `first_order_date` policz funkcja okna per klient.
- itp...

### `silver.order_items_enriched`

Cel:

- polaczyc pozycje zamowien z produktami,
- policzyc wartosci sprzedazy.

Wynik powinien zawierac:

- `order_item_id`,
- `order_id`,
- `product_id`,
- `product_name`,
- `category`,
- `quantity`,
- `unit_price`,
- `discount_percent`,
- `gross_value`,
- `discount_value`,
- `net_value`.

Wskazowki:

- `gross_value = quantity * unit_price`,
- `discount_value = quantity * unit_price * discount_percent / 100`,
- `net_value = quantity * unit_price * (1 - discount_percent / 100)`.
- itp...

## 7. Co masz zbudowac w warstwie gold

Warstwa `gold` to gotowe produkty danych dla analityka, dashboardu albo biznesu.

Utworz tabele:

- `gold.daily_sales_summary`,
- `gold.customer_analytics`,
- `gold.product_performance_monthly`.

### `gold.daily_sales_summary`

Grain:

```text
jeden wiersz = jeden dzien + kraj + kanal sprzedazy
```

Wynik powinien zawierac:

- `sales_date`,
- `country`,
- `sales_channel`,
- `orders_count`,
- `paid_orders_count`,
- `cancelled_orders_count`,
- `gross_revenue`,
- `discount_value`,
- `net_revenue`.

Zasady:

- licz revenue tylko dla oplaconych zamowien,
- uzyj danych z tabel silver,
- zaokraglij kwoty do 2 miejsc po przecinku.

### `gold.customer_analytics`

Grain:

```text
jeden wiersz = jeden klient
```

Wynik powinien zawierac:

- `customer_id`,
- `customer_name`,
- `country`,
- `first_order_date`,
- `last_order_date`,
- `orders_count`,
- `total_net_revenue`,
- `average_order_value`,
- `customer_lifetime_rank`.

Zasady:

- pokaz wszystkich klientow, rowniez tych bez zamowien,
- `total_net_revenue` licz tylko z oplaconych zamowien,
- dla klientow bez revenue pokaz `0`,
- `customer_lifetime_rank` policz funkcja okna po `total_net_revenue` malejaco.

### `gold.product_performance_monthly`

Grain:

```text
jeden wiersz = miesiac + produkt
```

Wynik powinien zawierac:

- `sales_month`,
- `category`,
- `product_id`,
- `product_name`,
- `units_sold`,
- `gross_revenue`,
- `net_revenue`,
- `category_rank_by_revenue`.

Zasady:

- uwzglednij tylko oplacone zamowienia,
- pogrupuj dane po miesiacu i produkcie,
- `category_rank_by_revenue` policz funkcja okna osobno dla miesiaca i kategorii.

## 8. Indeksy

Po utworzeniu warstw dodaj indeksy na kolumnach, po ktorych najczesciej filtrujesz albo laczysz dane.

## 9. Zapytania analityczne na koniec

Po zbudowaniu tabel przygotuj kilka zapytan, ktore odpowiadaja na pytania biznesowe.

Napisz query, ktore pokaze:

1. dzienna sprzedaz netto per kraj,
2. top 5 klientow po lacznym revenue,
3. top 3 produkty w kazdej kategorii i miesiacu,
4. miesieczna sprzedaz netto,
5. udzial rabatow w sprzedazy,
6. liczbe zamowien po statusie platnosci.