# 02 - OLTP, OLAP, normalizacja i denormalizacja

## Po co ta lekcja?

Ta sama firma moze miec dwa rozne sposoby przechowywania danych:

- jeden dobry dla aplikacji,
- drugi dobry dla analityki.

To jest bardzo wazne dla data engineera, bo dane z systemow aplikacyjnych rzadko sa od razu idealne do raportow.

Przyklad:

```text
Sklep internetowy musi szybko zapisac zamowienie klienta.
Analityk chce policzyc miesieczna sprzedaz per kraj i kategorie.
```

To sa dwie rozne potrzeby.

## OLTP

`OLTP` oznacza:

```text
Online Transaction Processing
```

Czyli system do obslugi codziennych operacji aplikacji.

Po ludzku:

```text
OLTP to baza, ktora pomaga aplikacji dzialac tu i teraz.
```

Przyklady operacji OLTP:

- klient zaklada konto,
- klient sklada zamowienie,
- aplikacja zmienia adres dostawy,
- system zapisuje platnosc,
- magazyn aktualizuje stan produktu,
- uzytkownik zmienia email.

W OLTP najwazniejsze jest to, zeby pojedyncza operacja byla:

- szybka,
- poprawna,
- spojna,
- bezpieczna transakcyjnie.

## Przyklad tabel OLTP

W sklepie internetowym model OLTP moze wygladac tak:

```text
customers
orders
order_items
products
payments
```

Kazda tabela ma swoja odpowiedzialnosc:

- `customers` - dane klienta,
- `products` - katalog produktow,
- `orders` - naglowek zamowienia,
- `order_items` - pozycje zamowienia,
- `payments` - informacje o platnosci.

Przyklad:

```text
orders nie trzyma nazwy klienta.
orders trzyma customer_id.
```

Dlaczego?

Bo nazwa klienta jest w `customers`. Gdy klient zmieni nazwisko albo email, nie chcemy poprawiac setek zamowien.

## Cechy OLTP

OLTP jest zoptymalizowane pod:

- duzo malych operacji,
- czeste `INSERT`, `UPDATE`, `DELETE`,
- transakcje,
- spojnosc danych,
- klucze glowne i obce,
- normalizacje.

Typowe zapytanie OLTP:

```sql
SELECT
    order_id,
    status,
    total_amount
FROM course.orders
WHERE order_id = 1001;
```

To jest maly odczyt konkretnego rekordu.

## OLAP

`OLAP` oznacza:

```text
Online Analytical Processing
```

Czyli system do analizy danych.

Po ludzku:

```text
OLAP to dane przygotowane do raportow, analiz i decyzji biznesowych.
```

Przyklady pytan OLAP:

- jaka byla sprzedaz miesieczna?
- ktore kraje generuja najwiekszy revenue?
- ktore produkty sprzedaja sie najlepiej?
- ilu klientow kupilo ponownie?
- jaki jest sredni koszyk w kanale mobile?
- jaki procent zamowien zostal anulowany?

## Przyklad tabel OLAP

W analityce mozemy miec tabele:

```text
mart.daily_sales
mart.customer_lifetime_value
mart.product_performance_monthly
star.fact_order_items
star.dim_customer
star.dim_product
```

One nie sa projektowane po to, zeby aplikacja szybko zapisala pojedyncze zamowienie.

One sa projektowane po to, zeby latwo liczyc metryki.

Przyklad:

```text
mart.daily_sales
```

moze miec kolumny:

- `sales_date`,
- `country`,
- `sales_channel`,
- `orders_count`,
- `net_revenue`,
- `cancelled_orders_count`.

To jest wygodne do dashboardu, ale niekoniecznie dobre jako glowna tabela aplikacji.

## Cechy OLAP

OLAP jest zoptymalizowane pod:

- duze odczyty,
- agregacje,
- raporty,
- dashboardy,
- porownania w czasie,
- funkcje okna,
- tabele faktow i wymiarow,
- czasem denormalizacje.

Typowe zapytanie OLAP:

```sql
SELECT
    DATE_TRUNC('month', sales_date) AS sales_month,
    country,
    SUM(net_revenue) AS total_revenue
FROM mart.daily_sales
GROUP BY
    DATE_TRUNC('month', sales_date),
    country
ORDER BY
    sales_month,
    total_revenue DESC;
```

To jest analiza wielu rekordow.

## OLTP vs OLAP

| Cecha | OLTP | OLAP |
|---|---|---|
| Cel | obsluga aplikacji | analiza i raportowanie |
| Operacje | male zapisy i odczyty | duze odczyty |
| Przyklady | zamowienie, platnosc, zmiana emaila | revenue, ranking, dashboard |
| Model | czesto znormalizowany | czesto analityczny lub denormalizowany |
| Uzytkownik | aplikacja, backend | analityk, BI, data team |
| Pytanie | czy to zamowienie zapisalo sie poprawnie? | ile zarobilismy w tym miesiacu? |

## Normalizacja

Normalizacja to sposob projektowania tabel tak, aby kazdy fakt byl zapisany w jednym miejscu.

Po ludzku:

```text
Nie powtarzaj tej samej informacji w wielu miejscach, jezeli mozesz trzymac ja raz i odwolywac sie przez klucz.
```

Przyklad:

Produkt ma nazwe i kategorie.

Zle byloby trzymac nazwe produktu w kazdej pozycji zamowienia:

```text
order_items:
order_id, product_id, product_name, category, quantity
```

Lepiej:

```text
products:
product_id, product_name, category

order_items:
order_item_id, order_id, product_id, quantity
```

Wtedy `order_items` mowi tylko:

```text
w tym zamowieniu kupiono ten produkt w takiej ilosci
```

A `products` mowi:

```text
ten product_id oznacza taka nazwe i taka kategorie
```

## Po co normalizacja?

Normalizacja pomaga:

- zmniejszyc duplikacje danych,
- uniknac sprzecznych informacji,
- latwiej aktualizowac dane,
- pilnowac integralnosci,
- projektowac czytelne relacje miedzy tabelami.

Przyklad problemu bez normalizacji:

```text
W jednym zamowieniu produkt nazywa sie "SQL Course".
W drugim "Sql course".
W trzecim "SQL Basics Course".
```

Czy to ten sam produkt? Nie wiadomo.

Jesli mamy `product_id`, problem jest mniejszy:

```text
product_id = 101
```

jednoznacznie wskazuje produkt.

## 1NF

Pierwsza postac normalna mowi:

```text
jedna komorka = jedna wartosc
```

Zle:

```text
customer_id | customer_name | ordered_products
1           | Anna          | SQL Course, Python Course, Excel Course
```

Problem:

- trudno policzyc produkty,
- trudno zrobic join,
- trudno filtrowac po jednym produkcie,
- trudno zapisac ilosc kazdego produktu.

Dobrze:

```text
order_items:
order_id | product_id | quantity
1001     | 101        | 1
1001     | 102        | 1
1001     | 103        | 1
```

Kazda wartosc jest osobno.

## 2NF

Druga postac normalna dotyczy sytuacji, gdzie tabela ma klucz zlozony albo naturalnie opisuje relacje kilku rzeczy.

Najprostsza intuicja:

```text
kolumny powinny opisywac caly wiersz, a nie tylko kawalek klucza
```

Przyklad problemu:

```text
order_items:
order_id, product_id, product_name, quantity
```

Jesli wiersz opisuje pozycje zamowienia, to:

- `quantity` opisuje pozycje zamowienia,
- `product_name` opisuje produkt.

`product_name` zalezy od `product_id`, a nie od calej pozycji zamowienia.

Lepiej:

```text
products:
product_id, product_name

order_items:
order_id, product_id, quantity
```

## 3NF

Trzecia postac normalna mowi:

```text
kolumny powinny opisywac klucz, a nie inna kolumne opisowa
```

Przyklad problemu:

```text
customers:
customer_id, customer_name, country_code, country_name
```

`country_name` zalezy od `country_code`, a nie bezposrednio od klienta.

Mozna to rozdzielic:

```text
customers:
customer_id, customer_name, country_code

countries:
country_code, country_name
```

W praktyce nie zawsze rozbijamy wszystko do maksimum, ale warto rozumiec zasade:

```text
czy ta kolumna naprawde opisuje glowny obiekt tej tabeli?
```

## Denormalizacja

Denormalizacja to celowe powtarzanie albo laczenie danych, zeby latwiej i szybciej je analizowac.

Po ludzku:

```text
Denormalizacja to kontrolowane odejscie od normalizacji dla wygody raportowania.
```

Przyklad:

Zamiast za kazdym razem laczyc:

```text
orders + customers + order_items + products
```

mozemy stworzyc:

```text
mart.sales_report
```

z kolumnami:

- `order_date`,
- `country`,
- `customer_name`,
- `product_name`,
- `category`,
- `quantity`,
- `net_revenue`.

To powtarza dane, ale bardzo ulatwia raportowanie.

## Kiedy denormalizacja jest dobra?

Denormalizacja jest dobra, gdy:

- tabela ma jasny grain,
- sluzy do raportowania,
- jest tworzona przez kontrolowany pipeline,
- wiadomo skad pochodza dane,
- metryki sa policzone w jednym miejscu,
- nie edytujemy jej recznie jako zrodla prawdy.

Przyklad dobry:

```text
gold.daily_sales_summary
```

Jeden wiersz oznacza:

```text
jeden dzien + jeden kraj + jeden kanal sprzedazy
```

## Kiedy denormalizacja jest zla?

Denormalizacja robi sie problemem, gdy:

- nie wiadomo, kto tworzy tabele,
- ta sama metryka jest liczona w wielu miejscach inaczej,
- nie wiadomo, jaki jest grain,
- dane sa recznie poprawiane,
- tabela raportowa zaczyna byc traktowana jak system zrodlowy.

Przyklad problemu:

```text
daily_sales_v1
daily_sales_final
daily_sales_final_new
daily_sales_dashboard_fix
```

Nikt nie wie, ktora tabela jest poprawna.

## Najwazniejsze dla data engineera

Nie chodzi o to, ze:

```text
normalizacja jest zawsze dobra
denormalizacja jest zawsze zla
```

Chodzi o to, zeby wiedziec, gdzie jestesmy:

```text
OLTP/source/core entity -> raczej normalizacja i integralnosc
OLAP/mart/dashboard -> czesto denormalizacja i wygoda analizy
```

## Mini sciaga

| Pojecie | Znaczenie |
|---|---|
| OLTP | system do codziennych operacji aplikacji |
| OLAP | system do analiz i raportow |
| Normalizacja | kazdy fakt zapisany w jednym miejscu |
| 1NF | jedna komorka ma jedna wartosc |
| 2NF | kolumny opisuja caly klucz/wiersz |
| 3NF | kolumny nie powinny zalezec od innych kolumn opisowych |
| Denormalizacja | kontrolowane powtarzanie/laczenie danych pod analityke |

## Co musisz umiec po tej lekcji?

Powinienes umiec:

- wyjasnic roznice OLTP vs OLAP,
- podac przyklad tabel aplikacyjnych i analitycznych,
- wyjasnic po co jest normalizacja,
- rozpoznac proste naruszenie 1NF, 2NF i 3NF,
- powiedziec kiedy denormalizacja ma sens,
- wskazac grain tabeli raportowej.

