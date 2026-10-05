# 07 - CDC, SCD i historia danych

## Po co ta lekcja?

Dane w systemach zrodlowych nie stoja w miejscu.

System zrodlowy ciagle:

- dopisuje nowe rekordy,
- aktualizuje istniejace rekordy,
- usuwa rekordy,
- zmienia statusy,
- poprawia bledy.

Data engineer musi zdecydowac:

```text
Czy w analityce chcemy widziec tylko aktualny stan, czy cala historie zmian?
```

To jest bardzo wazne, bo odpowiedz zmienia sposob projektowania tabel.

## Przyklad problemu

Klient zarejestrowal sie w Polsce:

```text
customer_id = 10
country = PL
```

Po kilku miesiacach przeprowadzil sie do Niemiec:

```text
customer_id = 10
country = DE
```

Pytanie:

```text
Czy raport sprzedazy historycznej ma pokazac jego stare zamowienia jako PL czy DE?
```

Jesli raport ma pokazywac stan aktualny, to wystarczy `DE`.

Jesli raport ma pokazywac prawde historyczna, to stare zamowienia powinny nadal byc przypisane do `PL`.

## Aktualny stan vs historia

Sa dwa podstawowe sposoby myslenia:

### Aktualny stan

Tabela pokazuje tylko najnowsza wersje rekordu.

Przyklad:

```text
customer_id | customer_name | country
10          | Anna          | DE
```

Nie wiemy juz, ze kiedys bylo `PL`.

### Historia zmian

Tabela przechowuje wiele wersji rekordu.

Przyklad:

```text
customer_id | customer_name | country | valid_from | valid_to   | is_current
10          | Anna          | PL      | 2026-01-01 | 2026-04-01 | false
10          | Anna          | DE      | 2026-04-01 | null       | true
```

Wtedy mozemy odpowiedziec na pytanie:

```text
Jaki kraj mial klient w dniu konkretnego zamowienia?
```

## Co to jest CDC?

`CDC` oznacza:

```text
Change Data Capture
```

Po ludzku:

```text
CDC to sposob przechwytywania informacji o tym, co zmienilo sie w systemie zrodlowym.
```

CDC moze informowac o operacjach:

- `INSERT` - pojawil sie nowy rekord,
- `UPDATE` - rekord zostal zmieniony,
- `DELETE` - rekord zostal usuniety.

Przyklad:

```text
customer_id = 10 zmienil country z PL na DE
```

Albo:

```text
order_id = 1001 zmienil status z pending na paid
```

## Po co jest CDC?

CDC pomaga:

- aktualizowac dane bez pelnego przeladowania wszystkiego,
- wykrywac zmienione rekordy,
- budowac incremental load,
- reagowac na usuniecia,
- utrzymywac historie zmian,
- synchronizowac dane miedzy systemami.

Bez CDC czesto trzeba robic:

```text
wez cala tabele jeszcze raz i porownaj z poprzednia wersja
```

Przy duzych danych to moze byc kosztowne.

## Jak moze wygladac CDC?

CDC moze przyjsc jako osobna tabela zdarzen.

Przyklad:

```text
raw.customer_changes
```

Kolumny:

- `operation`,
- `customer_id`,
- `customer_name`,
- `country`,
- `changed_at`.

Przykladowe dane:

```text
operation | customer_id | customer_name | country | changed_at
INSERT    | 10          | Anna          | PL      | 2026-01-01
UPDATE    | 10          | Anna          | DE      | 2026-04-01
DELETE    | 11          | Jan           | PL      | 2026-05-01
```

## Rodzaje podejsc do CDC

Na tym etapie wystarczy znac trzy intuicje.

### 1. CDC po kolumnie `updated_at`

Tabela zrodlowa ma kolumne:

```text
updated_at
```

Pipeline pobiera rekordy:

```sql
SELECT *
FROM source.customers
WHERE updated_at > TIMESTAMP '2026-04-01 00:00:00';
```

Zaleta:

- proste.

Wada:

- trzeba dobrze utrzymywac `updated_at`,
- usuniecia moga byc trudne do wykrycia.

### 2. CDC jako tabela zmian

System zapisuje kazda zmiane jako zdarzenie.

Przyklad:

```text
customer_changes
```

Zaleta:

- widzimy kolejne zmiany.

Wada:

- trzeba dobrze obsluzyc kolejnosc zdarzen.

### 3. CDC z logow bazy

Bardziej zaawansowane podejscie: narzedzie czyta log transakcyjny bazy.

Na tym kursie wystarczy wiedziec:

```text
Istnieja narzedzia, ktore potrafia czytac zmiany bez recznego porownywania tabel.
```

## Delete, hard delete i soft delete

Usuniecie danych tez jest waznym tematem.

### Hard delete

Rekord znika z tabeli.

```sql
DELETE FROM customers
WHERE customer_id = 10;
```

Problem:

```text
W analityce mozemy stracic informacje, ze klient kiedys istnial.
```

### Soft delete

Rekord zostaje, ale dostaje flage:

```text
is_deleted = true
```

Albo date:

```text
deleted_at = 2026-05-01
```

Przyklad:

```text
customer_id | customer_name | is_deleted | deleted_at
10          | Anna          | true       | 2026-05-01
```

W analityce soft delete jest czesto wygodniejszy, bo historia nie znika.

## Co to jest SCD?

`SCD` oznacza:

```text
Slowly Changing Dimension
```

Po ludzku:

```text
SCD to sposob przechowywania zmian w wymiarach, ktore zmieniaja sie w czasie.
```

Dotyczy zwykle wymiarow, np.:

- `dim_customer`,
- `dim_product`,
- `dim_employee`,
- `dim_store`,
- `dim_supplier`.

Przyklad:

Klient moze zmienic:

- kraj,
- segment,
- kanal pozyskania,
- opiekuna handlowego,
- status lojalnosciowy.

Produkt moze zmienic:

- kategorie,
- cene bazowa,
- marke,
- status aktywnosci.

## SCD Type 0

`SCD Type 0` oznacza:

```text
nie zmieniamy wartosci
```

To sa dane, ktore traktujemy jako stale.

Przyklad:

```text
customer_signup_date
```

Data rejestracji klienta zwykle nie powinna sie zmieniac.

Jesli w zrodle przyjdzie inna wartosc, mozemy ja zignorowac albo potraktowac jako blad danych.

## SCD Type 1

`SCD Type 1` oznacza:

```text
nadpisujemy stara wartosc nowa wartoscia
```

Przyklad:

```text
country: PL -> DE
```

Po zmianie widzimy tylko:

```text
DE
```

Nie znamy historii.

Przyklad tabeli:

```text
customer_id | customer_name | country
10          | Anna          | DE
```

SCD Type 1 jest prosty, ale traci historie.

## Kiedy SCD Type 1 ma sens?

SCD Type 1 ma sens, gdy:

- interesuje nas tylko aktualny stan,
- zmiana poprawia blad,
- historia nie ma znaczenia biznesowego,
- chcemy prostszy pipeline.

Przyklad:

```text
Poprawiono literowke w nazwisku klienta.
```

Nie zawsze chcemy pamietac bledna wersje nazwiska.

## SCD Type 2

`SCD Type 2` oznacza:

```text
tworzymy nowa wersje rekordu i zachowujemy historie
```

Tabela ma zwykle:

- `valid_from`,
- `valid_to`,
- `is_current`,
- czasem `version_number`.

Przyklad:

| customer_id | country | valid_from | valid_to | is_current |
|---|---|---|---|---|
| 10 | PL | 2026-01-01 | 2026-04-01 | false |
| 10 | DE | 2026-04-01 | null | true |

To pozwala zapytac:

```text
Jaki byl kraj klienta w dniu zamowienia?
```

## Jak czytac SCD Type 2?

Dla rekordu historycznego:

```text
valid_from = od kiedy wersja obowiazuje
valid_to = do kiedy wersja obowiazywala
is_current = czy to aktualna wersja
```

Aktualny rekord ma zwykle:

```text
valid_to = NULL
is_current = true
```

Historyczny rekord ma:

```text
valid_to ustawione na date konca
is_current = false
```

## Jak laczyc fakt z wymiarem SCD2?

Jesli fakt ma date zamowienia, a wymiar ma historie, join musi uwzgledniac zakres dat.

Przyklad:

```sql
SELECT
    f.order_id,
    f.order_date,
    c.customer_id,
    c.country,
    f.net_value
FROM fact_orders f
JOIN dim_customer_scd2 c
    ON f.customer_id = c.customer_id
   AND f.order_date >= c.valid_from
   AND (
        f.order_date < c.valid_to
        OR c.valid_to IS NULL
   );
```

Po ludzku:

```text
Dolacz taka wersje klienta, ktora byla aktywna w dniu zamowienia.
```

## SCD Type 1 vs Type 2

| Cecha | SCD Type 1 | SCD Type 2 |
|---|---|---|
| Historia | nie | tak |
| Prostota | prostsze | trudniejsze |
| Liczba rekordow | jeden rekord na encje | wiele wersji rekordu |
| Przyklad | poprawka literowki | zmiana kraju klienta |
| Pytanie | jaki jest aktualny stan? | jaki byl stan wtedy? |

## Mini przyklad: klient zmienia kraj

Zrodlo aktualne po zmianie:

```text
customer_id | country
10          | DE
```

SCD Type 1:

```text
customer_id | country
10          | DE
```

SCD Type 2:

```text
customer_id | country | valid_from | valid_to   | is_current
10          | PL      | 2026-01-01 | 2026-04-01 | false
10          | DE      | 2026-04-01 | null       | true
```

Roznica:

```text
SCD1 mowi: klient jest teraz w DE.
SCD2 mowi: klient byl w PL, a teraz jest w DE.
```

## Jak zbudowac SCD2 logicznie?

Gdy przychodzi zmiana:

1. znajdz aktualny rekord klienta,
2. porownaj kolumny, ktore sledzisz,
3. jesli nic sie nie zmienilo, nic nie rob,
4. jesli cos sie zmienilo, zamknij stary rekord,
5. wstaw nowy rekord jako aktualny.

Przyklad zamkniecia starego rekordu:

```sql
UPDATE dim_customer_scd2
SET
    valid_to = DATE '2026-04-01',
    is_current = false
WHERE customer_id = 10
  AND is_current = true;
```

Przyklad wstawienia nowej wersji:

```sql
INSERT INTO dim_customer_scd2 (
    customer_id,
    customer_name,
    country,
    valid_from,
    valid_to,
    is_current
)
VALUES (
    10,
    'Anna',
    'DE',
    DATE '2026-04-01',
    NULL,
    true
);
```

## Kiedy ktore podejscie?

SCD Type 0:

- gdy wartosc nie powinna sie zmieniac,
- np. data rejestracji.

SCD Type 1:

- gdy interesuje nas tylko aktualny stan,
- gdy zmiana poprawia blad,
- gdy historia nie jest potrzebna.

SCD Type 2:

- gdy raport musi pokazac stan z danego momentu,
- gdy zmiana wymiaru ma znaczenie biznesowe,
- gdy potrzebujemy audytu historii,
- gdy chcemy analizowac, jak zmiany w czasie wplywaly na wyniki.

## Typowe pytania data engineera

Przy kazdej zmianie danych warto zapytac:

- czy to jest poprawka bledu, czy realna zmiana biznesowa?
- czy potrzebujemy historii?
- czy raport historyczny ma sie zmienic po aktualizacji wymiaru?
- czy usuniecie ze zrodla ma usunac dane z analityki?
- czy potrzebujemy soft delete?
- po jakiej dacie laczymy fakt z wymiarem?

## Typowe bledy

### Blad 1: nadpisanie historii, ktora byla potrzebna

Problem:

```text
klient zmienil kraj, a wszystkie stare raporty nagle pokazaly nowy kraj
```

Rozwiazanie:

```text
uzyc SCD Type 2 dla kraju klienta, jesli historia jest wazna
```

### Blad 2: SCD2 bez zakresu dat w joinie

Problem:

```text
fakt laczy sie z wieloma wersjami klienta
```

Rozwiazanie:

```text
join po customer_id oraz zakresie valid_from/valid_to
```

### Blad 3: brak obslugi delete

Problem:

```text
rekord znika ze zrodla, ale nie wiadomo co zrobic w analityce
```

Rozwiazanie:

```text
ustalic zasade: hard delete, soft delete albo zamkniecie wersji historycznej
```

### Blad 4: traktowanie kazdej zmiany jako SCD2

Problem:

```text
tabela rosnie za szybko, historia nie wnosi wartosci
```

Rozwiazanie:

```text
sledzic historycznie tylko te atrybuty, ktore maja znaczenie biznesowe
```

## Najwazniejsze

Data engineer musi zawsze zapytac:

```text
Czy ta zmiana ma nadpisac dane, czy stworzyc nowa wersje historyczna?
```

CDC odpowiada na pytanie:

```text
co sie zmienilo?
```

SCD odpowiada na pytanie:

```text
jak przechowac historie tej zmiany w wymiarze?
```

## Mini sciaga

| Pojecie | Znaczenie |
|---|---|
| CDC | przechwytywanie zmian ze zrodla |
| INSERT | nowy rekord |
| UPDATE | zmiana rekordu |
| DELETE | usuniecie rekordu |
| Soft delete | rekord zostaje, ale jest oznaczony jako usuniety |
| SCD | historia zmian wymiaru |
| SCD Type 0 | nie zmieniamy wartosci |
| SCD Type 1 | nadpisujemy stara wartosc |
| SCD Type 2 | tworzymy nowa wersje rekordu |
| `valid_from` | od kiedy wersja obowiazuje |
| `valid_to` | do kiedy wersja obowiazywala |
| `is_current` | czy wersja jest aktualna |

## Co musisz umiec po tej lekcji?

Powinienes umiec:

- wyjasnic czym jest CDC,
- wyjasnic czym jest SCD,
- odroznic SCD Type 0, Type 1 i Type 2,
- powiedziec kiedy nadpisujemy dane,
- powiedziec kiedy przechowujemy historie,
- wyjasnic `valid_from`, `valid_to`, `is_current`,
- napisac prosty join faktu z wymiarem SCD2 po zakresie dat.

