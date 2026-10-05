# 09 - Batch, streaming, partycjonowanie i storage thinking

## Po co ta lekcja?

Data engineer nie tylko pisze SQL.

Musi tez rozumiec:

- jak dane przychodza,
- jak czesto dane sa przetwarzane,
- gdzie fizycznie albo logicznie leza dane,
- jak duzo danych czyta zapytanie,
- kiedy tabela robi sie za duza na proste podejscie.

Ta lekcja wprowadza trzy wazne tematy:

- `batch`,
- `streaming`,
- `partycjonowanie`.

## Batch

`Batch` oznacza przetwarzanie danych porcjami.

Po ludzku:

```text
Zbieramy dane przez jakis czas, a potem przetwarzamy je razem.
```

Przyklad:

```text
Codziennie o 02:00 przetwarzamy zamowienia z poprzedniego dnia.
```

Batch jest bardzo czesty w analityce, bo wiele raportow nie musi byc aktualizowanych co sekunde.

Przyklady batch:

- dzienny raport sprzedazy,
- miesieczne rozliczenie prowizji,
- nocne odswiezenie martow,
- import pliku CSV raz dziennie,
- przeliczenie tabeli `gold.daily_sales_summary`.

## Kiedy batch ma sens?

Batch ma sens, gdy:

- raport nie musi byc real-time,
- dane przychodza w paczkach,
- chcemy prostszy pipeline,
- latwo okreslic zakres przetwarzania, np. jeden dzien,
- wazniejsza jest stabilnosc niz natychmiastowosc.

Przyklad:

```text
Dashboard zarzadu odswiezany raz dziennie.
```

Nie potrzebuje streamingu. Batch wystarczy.

## Streaming

`Streaming` oznacza przetwarzanie danych blisko czasu rzeczywistego.

Po ludzku:

```text
Zdarzenie pojawia sie w systemie i prawie od razu jest przetwarzane.
```

Przyklad:

```text
Uzytkownik kliknal przycisk w aplikacji, a event trafia do systemu po kilku sekundach.
```

Przyklady streaming:

- klikniecia uzytkownikow,
- logi aplikacji,
- monitoring fraudow,
- alerty techniczne,
- lokalizacja pojazdow,
- transakcje wymagajace szybkiej reakcji.

## Dlaczego streaming jest trudniejszy?

Streaming jest trudniejszy, bo trzeba myslec o:

- opoznieniach,
- duplikatach,
- kolejnosci zdarzen,
- zdarzeniach spoznionych,
- oknach czasowych,
- ponownym przetwarzaniu,
- dokladnosci wynikow w czasie.

Przyklad problemu:

```text
Event z godziny 10:00 dotarl do systemu o 10:07.
```

Czy raport za okno 10:00-10:05 ma sie zmienic?

To sa problemy streamingowe.

## Batch vs streaming

| Cecha | Batch | Streaming |
|---|---|---|
| Kiedy dane sa przetwarzane? | porcjami | prawie na biezaco |
| Typowa czestotliwosc | dziennie, godzinowo, miesiecznie | sekundy/minuty |
| Trudnosc | nizsza | wyzsza |
| Przyklad | dzienny raport | live events |
| Typowe problemy | rerun, idempotencja | late events, duplicates, okna czasowe |
| Czy zawsze potrzebny? | bardzo czesto tak | tylko gdy biznes tego wymaga |

Najwazniejsze:

```text
Nie kazdy problem wymaga streamingu.
```

Jesli raport moze byc odswiezony raz dziennie, batch jest zwykle prostszy i tanszy.

## Partycjonowanie

Partycjonowanie oznacza podzial duzej tabeli na mniejsze czesci.

Po ludzku:

```text
Zamiast trzymac jedna ogromna tabele, dzielimy ja na logiczne kawalki.
```

Najczestszy podzial w analityce:

```text
po dacie
```

Przyklad:

```text
orders_2026_01
orders_2026_02
orders_2026_03
```

Albo w PostgreSQL jako jedna tabela partycjonowana:

```text
course.orders_partitioned
```

z partycjami miesiecznymi.

## Po co partycjonowanie?

Partycjonowanie pomaga, gdy tabela jest duza i zapytania zwykle czytaja tylko fragment danych.

Przyklad:

Tabela ma dane za 5 lat.

Zapytanie pyta tylko o marzec 2026:

```sql
WHERE order_date >= DATE '2026-03-01'
  AND order_date < DATE '2026-04-01'
```

Z partycjonowaniem po `order_date` baza moze pominac partycje z innych miesiecy.

## Partition pruning

`Partition pruning` oznacza:

```text
silnik pomija partycje, ktore nie sa potrzebne dla zapytania
```

Przyklad:

Masz partycje:

```text
orders_2026_01
orders_2026_02
orders_2026_03
orders_2026_04
```

Zapytanie:

```sql
SELECT *
FROM course.orders_partitioned
WHERE order_date >= DATE '2026-03-01'
  AND order_date < DATE '2026-04-01';
```

Silnik powinien czytac tylko:

```text
orders_2026_03
```

A pominac pozostale miesiace.

## Przyklad partycjonowania w PostgreSQL

Tworzymy tabele partycjonowana po `order_date`.

```sql
DROP TABLE IF EXISTS course.orders_partitioned CASCADE;

CREATE TABLE course.orders_partitioned (
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL
) PARTITION BY RANGE (order_date);
```

Ta tabela jest tabela nadrzedna.

Nie przechowuje danych sama w sobie tak jak zwykla tabela. Dane trafiaja do partycji.

## Tworzenie partycji miesiecznych

```sql
CREATE TABLE course.orders_2026_01
PARTITION OF course.orders_partitioned
FOR VALUES FROM (DATE '2026-01-01') TO (DATE '2026-02-01');

CREATE TABLE course.orders_2026_02
PARTITION OF course.orders_partitioned
FOR VALUES FROM (DATE '2026-02-01') TO (DATE '2026-03-01');

CREATE TABLE course.orders_2026_03
PARTITION OF course.orders_partitioned
FOR VALUES FROM (DATE '2026-03-01') TO (DATE '2026-04-01');
```

Zakres `FROM` jest wlaczny, a `TO` jest wylaczny.

Czyli:

```text
FROM 2026-03-01 TO 2026-04-01
```

obejmuje marzec, ale nie obejmuje `2026-04-01`.

## Wstawianie danych do tabeli partycjonowanej

Wstawiamy do tabeli nadrzednej:

```sql
INSERT INTO course.orders_partitioned (
    order_id,
    customer_id,
    order_date,
    status,
    total_amount
)
VALUES
(1, 101, DATE '2026-01-10', 'paid', 120.00),
(2, 102, DATE '2026-02-15', 'paid', 80.00),
(3, 103, DATE '2026-03-20', 'cancelled', 50.00);
```

PostgreSQL sam kieruje rekord do odpowiedniej partycji na podstawie `order_date`.

## Zapytanie korzystajace z partycji

```sql
EXPLAIN
SELECT *
FROM course.orders_partitioned
WHERE order_date >= DATE '2026-03-01'
  AND order_date < DATE '2026-04-01';
```

W planie wykonania powinienes zobaczyc, ze PostgreSQL nie musi czytac wszystkich partycji.

Przy malych danych roznica czasu moze byc niewielka, ale przy milionach rekordow ma to duze znaczenie.

## Zly warunek moze utrudnic pruning

Dobrze:

```sql
WHERE order_date >= DATE '2026-03-01'
  AND order_date < DATE '2026-04-01'
```

Gorzej:

```sql
WHERE DATE_TRUNC('month', order_date) = DATE '2026-03-01'
```

Dlaczego?

Bo funkcja na kolumnie moze utrudnic silnikowi wykorzystanie partycji albo indeksu.

Prosta zasada:

```text
W filtrze po partycji staraj sie filtrowac bezposrednio po kolumnie partycjonujacej.
```

## Partycjonowanie a indeksy

Partycjonowanie i indeksy to nie to samo.

Indeks:

```text
pomaga szybko znalezc konkretne wiersze
```

Partycjonowanie:

```text
pomaga pominac cale fragmenty tabeli
```

W praktyce czesto uzywa sie obu.

Przyklad:

- tabela jest partycjonowana po `order_date`,
- w kazdej partycji mamy indeks po `customer_id`.

## Po czym partycjonowac?

Najczesciej po kolumnie, po ktorej czesto filtrujesz i ktora naturalnie dzieli dane.

Typowe kolumny:

- `order_date`,
- `event_date`,
- `created_at`,
- `loaded_at`,
- `sales_month`.

Dobre pytania:

- czy tabela rosnie w czasie?
- czy zapytania czesto filtruja po dacie?
- czy czesto usuwamy/archiwizujemy stare dane?
- czy partycja bedzie miala sensowny rozmiar?

## Kiedy partycjonowanie ma sens?

Partycjonowanie ma sens, gdy:

- tabela jest duza,
- dane rosna regularnie,
- zapytania czytaja konkretne zakresy czasu,
- czesto przeladowujesz konkretne dni/miesiace,
- chcesz latwiej archiwizowac stare dane,
- chcesz przyspieszyc zapytania przez pruning.

Przyklad:

```text
Tabela eventow ma 2 miliardy rekordow i wiekszosc zapytan pyta o ostatnie 7 dni.
```

Partycjonowanie po dacie moze byc bardzo pomocne.

## Kiedy partycjonowanie nie ma sensu?

Partycjonowanie moze nie miec sensu, gdy:

- tabela jest mala,
- zapytania zwykle czytaja cala tabele,
- nie ma naturalnej kolumny do podzialu,
- partycji byloby bardzo duzo,
- kazda partycja bylaby bardzo mala.

Przyklad:

```text
Tabela ma 1000 wierszy i partycje dzienne przez 3 lata.
```

To moze byc wolniejsze i bardziej skomplikowane niz jedna zwykla tabela.

## Over-partitioning

`Over-partitioning` oznacza:

```text
za duzo zbyt malych partycji
```

Problem:

- wiecej obiektow do zarzadzania,
- bardziej skomplikowane plany zapytan,
- wiekszy narzut metadanych,
- trudniejsze utrzymanie.

## Storage thinking

`Storage thinking` oznacza, ze data engineer mysli nie tylko o wyniku zapytania, ale tez o tym, jak dane sa przechowywane i czytane.

Pytania:

- jak duza jest tabela?
- po czym najczesciej filtrujemy?
- czy dane rosna codziennie?
- czy potrzebujemy historii?
- czy query czyta 1% tabeli czy 90% tabeli?
- czy czesc danych mozna pominac?
- czy starsze dane sa rzadko czytane?

## Najwazniejsze

Nie kazdy problem wymaga streamingu.

Nie kazda tabela wymaga partycjonowania.

Najpierw rozumiemy sposob uzycia danych, potem wybieramy technike.

## Mini sciaga

| Pojecie | Znaczenie |
|---|---|
| Batch | przetwarzanie danych porcjami |
| Streaming | przetwarzanie zdarzen prawie na biezaco |
| Partycjonowanie | podzial duzej tabeli na mniejsze czesci |
| Partition pruning | pominiecie niepotrzebnych partycji |
| Over-partitioning | zbyt wiele malych partycji |
| Storage thinking | myslenie o tym, jak dane sa przechowywane i czytane |

## Co musisz umiec po tej lekcji?

Powinienes umiec:

- wyjasnic batch,
- wyjasnic streaming,
- powiedziec kiedy streaming jest potrzebny,
- wyjasnic partycjonowanie,
- napisac prosty przyklad tabeli partycjonowanej po dacie,
- wyjasnic partition pruning,
- powiedziec kiedy partycjonowanie ma sens,
- powiedziec czym jest over-partitioning.

