=========================================
Implementacja Bazy Danych
=========================================

:Autorzy:
    1. Oskar Wrona
    2. Kamil Lewandowski
    3. Adam Tarkowski

Implementacja fizycznych schematów
=====================================

Schemat bazy zaimplementowano w dwóch wariantach: dla PostgreSQL oraz SQLite.
Obie wersje zachowują ten sam układ tabel, kluczy głównych i obcych oraz
podstawowych więzów integralności. Różnice dotyczą przede wszystkim typów danych
i sposobu automatycznego generowania identyfikatorów.

.. figure:: schemat_fizyczny_postgres.png
   :align: center
   :alt: Model fizyczny ERD dla PostgreSQL

   Fizyczny schemat bazy danych opracowany dla silnika PostgreSQL.

.. figure:: schemat_fizyczny_sqlite.png
   :align: center
   :alt: Model fizyczny ERD dla SQLite

   Fizyczny schemat bazy danych opracowany dla silnika SQLite.

Kod SQL dla PostgreSQL
----------------------

Ten sam skrypt jest dostępny jako osobny plik:
:download:`utworz_baze_postgresql.sql <utworz_baze_postgresql.sql>`.

.. literalinclude:: utworz_baze_postgresql.sql
   :language: sql
   :linenos:

Reprezentacja bazy danych w pgadmin na zdalnym serwerze:

.. figure:: dowod_ze_zdalnego_postgres.png
   :align: center
   :alt: Zrzut ekranu z pgAdmin przedstawiający strukturę bazy danych

   Lista tabel utworzonych na zdalnym serwerze PostgreSQL w pgAdmin.

Reprezentacja bazy danych w psql na lokalnym serwerze:

.. figure:: dowod_z_lokalnego_serwera.png
   :align: center
   :alt: Lista relacji bazy danych wyświetlona w programie psql

   Lista relacji bazy danych wyświetlona lokalnie w programie psql.

Kod SQL dla SQLite
------------------

Ten sam skrypt jest dostępny jako osobny plik:
:download:`utworz_baze_sqlite.sql <utworz_baze_sqlite.sql>`.

.. literalinclude:: utworz_baze_sqlite.sql
   :language: sql
   :linenos:

Reprezentacja bazy danych w sqlite:

.. figure:: dowod_z_sqlite.png
   :align: center
   :alt: Zrzut ekranu reprezentacji sqlite z jupyterhub

   Lista tabel utworzonych w bazie SQLite w środowisku JupyterHub.


Skrypt do wprowadzania danych do bazy danych
===============================================

Wybór mechanizmu importu
------------------------

Do wsadowego zasilania obu baz wybrano plik CSV oraz skrypty napisane
w języku Python. Takie rozwiązanie pozwala wykorzystać ten sam zestaw danych
wejściowych dla PostgreSQL i SQLite, a jednocześnie przeprowadzić walidację
wartości przed wykonaniem instrukcji ``INSERT``. W pliku przyjęto separator
średnikowy, ponieważ dane tekstowe mogą zawierać przecinki.

Każdy wiersz CSV opisuje jedną pozycję zamówienia. Pole
``ID_Zamowienia`` jest obowiązkowe i musi mieć tę samą wartość we wszystkich
wierszach należących do jednego zamówienia. Dzięki temu kilka produktów
kupionych w ramach jednej transakcji nie jest błędnie interpretowanych jako
kilka oddzielnych zamówień. Informacje dotyczące klienta, płatności i wysyłki
mogą powtarzać się w takich wierszach, ale skrypt zapisuje odpowiadające im
rekordy tylko raz.

Przed rozpoczęciem zapisu wiersze są grupowane według ``ID_Zamowienia``.
Wszystkie pozycje jednego zamówienia są następnie obsługiwane w ramach jednej
transakcji. Dzięki temu błąd dowolnej pozycji wycofuje całe zamówienie, a nie
pozostawia w bazie jego niekompletnej części.

W przypadku PostgreSQL identyfikatory pomocnicze są pobierane z sekwencji
powiązanych z kolumnami typu ``SERIAL``. Po zakończeniu importu sekwencje są
synchronizowane również z identyfikatorami przekazanymi jawnie w pliku CSV.
W SQLite brakujące identyfikatory są wyznaczane podczas sekwencyjnego importu
prowadzonego w ramach jednego połączenia, a kolumny kluczy głównych korzystają
z mechanizmu ``AUTOINCREMENT``. Po otwarciu połączenia włączana jest ponadto
obsługa kluczy obcych za pomocą ``PRAGMA foreign_keys = ON``.

Do PostgreSQL
-------------

Samodzielny skrypt importujący jest dostępny w pliku:
:download:`import_postgresql.py <import_postgresql.py>`.

.. literalinclude:: import_postgresql.py
   :language: python
   :linenos:

Do SQLite
---------

Samodzielny skrypt importujący jest dostępny w pliku:
:download:`import_sqlite.py <import_sqlite.py>`.

.. literalinclude:: import_sqlite.py
   :language: python
   :linenos:

Komentarz do procesu wprowadzania danych
----------------------------------------

Rekordy są przetwarzane zgodnie z kolejnością zależności pomiędzy tabelami.
Najpierw tworzone lub wyszukiwane są dane klienta, kategorii, producenta i kodu
rabatowego. Następnie skrypt obsługuje produkt i zamówienie, a dopiero później
płatność, wysyłkę, pozycję zamówienia oraz opcjonalną opinię. Przed dodaniem
rekordu sprawdzane jest istnienie wymaganych rekordów nadrzędnych.

Każde zamówienie jest przetwarzane w osobnej transakcji. Po poprawnym
przetworzeniu wszystkich jego wierszy wykonywany jest ``commit``, natomiast
wystąpienie błędu w dowolnej pozycji powoduje ``rollback`` całego zamówienia.
Komunikat błędu zawiera identyfikator zamówienia i numery wszystkich jego
wierszy, co ułatwia odnalezienie niepoprawnych wartości w pliku źródłowym.

Skrypt sprawdza między innymi zakres zniżki i oceny, dodatnią liczbę sztuk,
nieujemne ceny i stany magazynowe oraz istnienie rekordów wskazywanych przez
klucze obce. Płatność i wysyłka są identyfikowane na podstawie zamówienia,
a opinia na podstawie pary: zamówienie i produkt. Zapobiega to tworzeniu
duplikatów podczas importu kolejnych pozycji należących do tej samej transakcji.
Opinia może zostać dodana wyłącznie do zamówienia o statusie ``Dostarczone``.
Produkt jest wyszukiwany na podstawie nazwy i producenta, a kolejne wystąpienia
klienta, produktu, kodu, płatności, wysyłki i zamówienia są porównywane z już
zapisanymi danymi. Sprzeczne wartości powodują wycofanie całej transakcji.
Importer kontroluje również słowniki statusów oraz zapisuje w zamówieniu
historyczną wartość zastosowanego rabatu. Pole ``Stan_magazynowy`` jest w tym
ćwiczeniu importowanym stanem danych, a nie mechanizmem realizacji magazynowej;
skrypt nie symuluje automatycznego wydania towaru.
