# 01 - ETL, ELT i architektura danych

## Po co data engineerowi architektura danych?

Pisanie SQL-a to tylko czesc pracy.

Data engineer musi tez wiedziec:

- skad dane przychodza,
- gdzie sa przechowywane,
- kiedy sa czyszczone,
- kto moze z nich korzystac,
- ktora tabela jest surowa, a ktora gotowa do raportowania.

Bez architektury danych latwo powstaje chaos:

- kilka osob liczy ten sam KPI inaczej,
- raporty korzystaja z surowych danych,
- nie wiadomo, ktora tabela jest aktualna,
- pipeline po ponownym uruchomieniu robi duplikaty.

## Co to jest ETL?

`ETL` oznacza:

```text
Extract -> Transform -> Load
```

Czyli:

1. `Extract` - pobierz dane ze zrodla,
2. `Transform` - przeksztalc dane poza docelowa baza,
3. `Load` - zaladuj gotowy wynik do bazy/hurtowni.

Po ludzku:

```text
najpierw bierzemy dane, potem je czyscimy i dopiero na koncu zapisujemy gotowa tabele
```

W ETL transformacja dzieje sie przed zaladowaniem danych do docelowego miejsca. To oznacza, ze do bazy/hurtowni czesto trafia juz wynik po czyszczeniu.

### Przyklad ETL 1 - plik CSV z zamowieniami

```text
CSV z zamowieniami
-> Python poprawia daty, usuwa duplikaty, standaryzuje statusy
-> gotowa tabela orders_clean w PostgreSQL
```

Przykladowe transformacje:

- zamiana tekstu `'2026/01/05'` na typ `DATE`,
- zmiana statusu `'PAID'`, `'paid'`, `'Paid'` na jedna wartosc `'paid'`,
- usuniecie duplikatow zamowien,
- policzenie `total_amount`,
- odrzucenie rekordow z blednym `customer_id`.

### Przyklad ETL 2 - dane z API pogodowego

```text
API pogodowe
-> skrypt pobiera JSON i zamienia go na tabele
-> skrypt liczy srednia temperature dzienna
-> gotowy wynik trafia do tabeli weather_daily
```

W takim podejsciu baza dostaje juz dane przygotowane. Surowy JSON moze w ogole nie zostac zapisany w bazie.

### Kiedy ETL ma sens?

ETL ma sens, gdy:

- dane trzeba mocno przygotowac przed zapisem,
- docelowa baza nie powinna trzymac surowych danych,
- transformacje sa trudne do wykonania w SQL,
- firma ma starsza hurtownie, ktora nie jest dobra do ciezkich transformacji,
- chcemy kontrolowac dane zanim trafia do glownego systemu analitycznego.

## Co to jest ELT?

`ELT` oznacza:

```text
Extract -> Load -> Transform
```

Czyli:

1. `Extract` - pobierz dane,
2. `Load` - zaladuj dane surowe do platformy danych,
3. `Transform` - przeksztalc dane juz w bazie/hurtowni/lakehouse.

Po ludzku:

```text
najpierw zapisujemy dane surowe, a dopiero potem robimy z nich czyste tabele i raporty
```

W ELT surowe dane trafiaja do bazy lub lakehouse. Dopiero potem SQL-em budujemy kolejne warstwy.

### Przyklad ELT 1 - e-commerce

```text
system sklepu
-> raw.orders
-> staging.stg_orders
-> core.orders
-> mart.daily_sales
```

Co dzieje sie po drodze:

- `raw.orders` trzyma dane blisko zrodla,
- `staging.stg_orders` poprawia typy i nazwy kolumn,
- `core.orders` ma juz biznesowo poprawne statusy i klucze,
- `mart.daily_sales` jest gotowy pod raport.

### Przyklad ELT 2 - platnosci

```text
system platnosci
-> raw.payments
-> staging.stg_payments
-> core.payments
-> mart.payment_success_rate
```

W `raw.payments` mozemy miec statusy dokladnie takie, jak przyszly ze zrodla:

```text
SUCCESS, success, paid, FAILED, error
```

W `core.payments` mozemy juz miec jedna wspolna logike:

```text
is_successful_payment = true/false
```

### Kiedy ELT ma sens?

ELT ma sens, gdy:

- chcemy trzymac surowe dane do audytu,
- chcemy moc odtworzyc pipeline od poczatku,
- transformacje da sie dobrze napisac w SQL,
- hurtownia/lakehouse dobrze radzi sobie z duzymi danymi,
- wiele zespolow korzysta z tych samych warstw danych,
- chcemy rozdzielic dane surowe, oczyszczone i raportowe.

W nowoczesnej analityce bardzo czesto uzywa sie ELT, bo bazy, hurtownie i lakehouse dobrze wykonuja SQL na duzych danych.

## ETL vs ELT

| Cecha | ETL | ELT |
|---|---|---|
| Kiedy transformujemy? | przed zaladowaniem | po zaladowaniu |
| Gdzie jest raw data? | czasem nie trafia do hurtowni | zwykle trafia do warstwy raw |
| Typowe narzedzia | Python, Spark, ETL tools | SQL, dbt, Spark SQL |
| Zaleta | kontrola przed zapisem | latwy replay i audyt |

## Prosty obraz roznicy

ETL:

```text
zrodlo -> czyszczenie poza baza -> gotowa tabela w bazie
```

ELT:

```text
zrodlo -> surowa tabela w bazie -> czyszczenie SQL-em -> gotowa tabela raportowa
```

Najkrotsza roznica:

```text
ETL: transformujesz przed zapisem do hurtowni.
ELT: zapisujesz surowe dane i transformujesz juz w hurtowni.
```

## Przyklad na tych samych danych

Zalozmy, ze dostajesz plik z zamowieniami:

```text
order_id, customer_id, order_date, status, amount
1, 10, 2026/01/05, PAID, 100
2, 11, 05-01-2026, Cancelled, 50
3, 12, brak, paid, 80
```

### Podejscie ETL

Najpierw skrypt poza baza:

- poprawia format dat,
- standaryzuje statusy,
- usuwa albo oznacza bledne rekordy,
- dopiero potem laduje wynik do tabeli.

Do bazy trafia np.:

```text
analytics.orders_clean
```

### Podejscie ELT

Najpierw ladujesz wszystko do tabeli:

```text
raw.orders
```

Potem SQL-em tworzysz:

```text
staging.stg_orders
core.orders
mart.daily_sales
```

Dzieki temu masz i dane surowe, i kolejne wersje przetworzone.

## Co to jest pipeline danych?

Pipeline danych to ciag krokow, ktore prowadza od danych zrodlowych do danych uzytecznych biznesowo.

Przyklad:

```text
raw orders
-> staging orders
-> core orders
-> mart daily revenue
```

Kazdy krok powinien miec jasna odpowiedzialnosc.

## Dlaczego data engineer powinien to rozumiec?

Bo data engineer odpowiada nie tylko za to, zeby zapytanie zadzialalo.

Odpowiada tez za to, zeby:

- dane byly powtarzalnie przetwarzane,
- mozna bylo znalezc blad w pipeline,
- raporty mialy jedno zrodlo prawdy,
- dalo sie odtworzyc wynik,
- surowe dane nie mieszaly sie z raportowymi,
- transformacje byly czytelne dla innych osob.

Przyklad problemu:

```text
Analityk liczy revenue z tabeli orders.
Drugi analityk liczy revenue z order_items.
Dashboard pokazuje inne liczby.
```

Architektura danych pomaga ustalic:

```text
Revenue do raportow bierzemy z gold.daily_sales_summary.
```

I wtedy zespol nie liczy tej samej metryki na piec roznych sposobow.

## Co musi umiec kursant na koniec lekcji?

Powinien umiec powiedziec:

- co znaczy ETL,
- co znaczy ELT,
- czym sie roznia,
- dlaczego w analityce warto trzymac raw data,
- czym jest pipeline danych.
