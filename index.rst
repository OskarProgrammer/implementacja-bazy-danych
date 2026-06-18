=========================================
Sprawozdanie: Implementacja Bazy Danych
=========================================

:Autorzy:
    1. Oskar Wrona
    2. Kamil Lewandowski
    3. Adam Tarkowski


Poniższe opracowanie dotyczy wymagania: **Definiowanie bazy danych i wprowadzanie danych do bazy**.
Dokument zachowuje podział na dwa warianty silnika bazodanowego oraz pokazuje pełną ścieżkę od definicji schematu fizycznego do załadowania danych z pliku wejściowego.
Wymaganie jest realizowane przez:

- definicję bazy danych w wariancie PostgreSQL,
- definicję bazy danych w wariancie SQLite,
- skrypty importujące dane z pliku CSV do obu baz,
- uzasadnienie wyboru mechanizmów wsadowego wprowadzania danych,
- komentarz opisujący przebieg importu oraz kontrolę poprawności danych.

1. Implementacja fizycznych schematów
=====================================


W tej części zdefiniowano relacyjną bazę danych dla przykładowego sklepu internetowego.
Model obejmuje tabele odpowiedzialne za klientów, kategorie, producentów, kody rabatowe, produkty, zamówienia, pozycje zamówień, płatności, wysyłki oraz opinie.
Taki podział pozwala uniknąć przechowywania wszystkich informacji w jednej płaskiej tabeli i umożliwia kontrolowanie zależności między encjami za pomocą kluczy głównych, kluczy obcych, ograniczeń ``CHECK`` oraz indeksów.

Przygotowano dwa warianty tego samego modelu: pierwszy dla PostgreSQL, a drugi dla SQLite.
Oba warianty opisują tę samą logikę biznesową, ale różnią się składnią DDL, typami danych oraz sposobem obsługi automatycznie generowanych identyfikatorów.

.. figure:: schemat_fizyczny_postgres.png
   :align: center
   :alt: Model fizyczny ERD dla PostgreSQL

   Rysunek 4: Fizyczny schemat bazy danych opracowany dla silnika PostgreSQL.

.. figure:: schemat_fizyczny_sqlite.png
   :align: center
   :alt: Model fizyczny ERD dla SQLite

   Rysunek 4: Fizyczny schemat bazy danych opracowany dla silnika SQLite.


Wariant PostgreSQL
------------------

Wariant PostgreSQL wykorzystuje mechanizmy typowe dla serwerowego systemu zarządzania bazą danych.
Identyfikatory techniczne są tworzone za pomocą typu ``SERIAL``, kwoty przechowywane są w typie ``NUMERIC(10,2)``, a daty zamówień w typie ``TIMESTAMP``.
W skrypcie zastosowano również nazwane ograniczenia kluczy obcych, reguły ``ON DELETE CASCADE`` oraz ``ON DELETE SET NULL``, dzięki czemu baza samodzielnie pilnuje spójności danych przy usuwaniu rekordów nadrzędnych.
Indeksy dodane na kolumnach często używanych w relacjach przyspieszają wyszukiwanie produktów, zamówień, płatności i wysyłek.

Kod dla PGADMINA::

   -- =========================================
   -- TWORZENIE TABEL - SKLEP INTERNETOWY
   -- PostgreSQL / pgAdmin
   -- =========================================

   -- Usuwanie tabel jeśli istnieją
   DROP TABLE IF EXISTS Opinie CASCADE;
   DROP TABLE IF EXISTS Wysylki CASCADE;
   DROP TABLE IF EXISTS Platnosci CASCADE;
   DROP TABLE IF EXISTS Pozycje_Zamowienia CASCADE;
   DROP TABLE IF EXISTS Zamowienia CASCADE;
   DROP TABLE IF EXISTS Produkty CASCADE;
   DROP TABLE IF EXISTS Kody_Rabatowe CASCADE;
   DROP TABLE IF EXISTS Kategorie CASCADE;
   DROP TABLE IF EXISTS Producenci CASCADE;
   DROP TABLE IF EXISTS Klienci CASCADE;

   -- =========================================
   -- TABELA: Klienci
   -- =========================================
   CREATE TABLE Klienci (
      ID_Klienta SERIAL PRIMARY KEY,
      Imie VARCHAR(50) NOT NULL,
      Nazwisko VARCHAR(50) NOT NULL,
      Email VARCHAR(255) UNIQUE NOT NULL,
      Telefon VARCHAR(15),
      Miasto VARCHAR(100),
      Ulica VARCHAR(150),
      Kod_Pocztowy VARCHAR(10)
   );

   -- =========================================
   -- TABELA: Kategorie
   -- =========================================
   CREATE TABLE Kategorie (
      ID_Kategorii SERIAL PRIMARY KEY,
      Nazwa_kategorii VARCHAR(50) NOT NULL
   );

   -- =========================================
   -- TABELA: Producenci
   -- =========================================
   CREATE TABLE Producenci (
      ID_Producenta SERIAL PRIMARY KEY,
      Nazwa_producenta VARCHAR(100) NOT NULL,
      Kraj_pochodzenia VARCHAR(50)
   );

   -- =========================================
   -- TABELA: Kody_Rabatowe
   -- =========================================
   CREATE TABLE Kody_Rabatowe (
      ID_Kodu SERIAL PRIMARY KEY,
      Kod_tekstowy VARCHAR(20) UNIQUE NOT NULL,
      Znizka_procentowa SMALLINT CHECK (Znizka_procentowa BETWEEN 0 AND 100)
   );

   -- =========================================
   -- TABELA: Produkty
   -- =========================================
   CREATE TABLE Produkty (
      ID_Produktu SERIAL PRIMARY KEY,
      ID_Kategorii INTEGER,
      ID_Producenta INTEGER,
      Nazwa VARCHAR(150) NOT NULL,
      Opis TEXT,
      Cena_aktualna NUMERIC(10,2) NOT NULL CHECK (Cena_aktualna >= 0),
      Stan_magazynowy INTEGER NOT NULL DEFAULT 0 CHECK (Stan_magazynowy >= 0),

      CONSTRAINT fk_produkty_kategorie
         FOREIGN KEY (ID_Kategorii)
         REFERENCES Kategorie(ID_Kategorii)
         ON DELETE SET NULL,

      CONSTRAINT fk_produkty_producenci
         FOREIGN KEY (ID_Producenta)
         REFERENCES Producenci(ID_Producenta)
         ON DELETE SET NULL
   );

   -- =========================================
   -- TABELA: Zamowienia
   -- =========================================
   CREATE TABLE Zamowienia (
      ID_Zamowienia SERIAL PRIMARY KEY,
      ID_Klienta INTEGER NOT NULL,
      ID_Kodu INTEGER,
      Data_zamowienia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      Status_zamowienia VARCHAR(30) NOT NULL,

      CONSTRAINT fk_zamowienia_klienci
         FOREIGN KEY (ID_Klienta)
         REFERENCES Klienci(ID_Klienta)
         ON DELETE CASCADE,

      CONSTRAINT fk_zamowienia_kody
         FOREIGN KEY (ID_Kodu)
         REFERENCES Kody_Rabatowe(ID_Kodu)
         ON DELETE SET NULL
   );

   -- =========================================
   -- TABELA: Platnosci
   -- =========================================
   CREATE TABLE Platnosci (
      ID_Platnosci SERIAL PRIMARY KEY,
      ID_Zamowienia INTEGER NOT NULL,
      Metoda_platnosci VARCHAR(50) NOT NULL,
      Status_platnosci VARCHAR(30) NOT NULL,

      CONSTRAINT fk_platnosci_zamowienia
         FOREIGN KEY (ID_Zamowienia)
         REFERENCES Zamowienia(ID_Zamowienia)
         ON DELETE CASCADE
   );

   -- =========================================
   -- TABELA: Pozycje_Zamowienia
   -- =========================================
   CREATE TABLE Pozycje_Zamowienia (
      ID_Zamowienia INTEGER NOT NULL,
      ID_Produktu INTEGER NOT NULL,
      Ilosc INTEGER NOT NULL CHECK (Ilosc > 0),
      Cena_historyczna NUMERIC(10,2) NOT NULL CHECK (Cena_historyczna >= 0),

      PRIMARY KEY (ID_Zamowienia, ID_Produktu),

      CONSTRAINT fk_pozycje_zamowienia
         FOREIGN KEY (ID_Zamowienia)
         REFERENCES Zamowienia(ID_Zamowienia)
         ON DELETE CASCADE,

      CONSTRAINT fk_pozycje_produkty
         FOREIGN KEY (ID_Produktu)
         REFERENCES Produkty(ID_Produktu)
         ON DELETE CASCADE
   );

   -- =========================================
   -- TABELA: Wysylki
   -- =========================================
   CREATE TABLE Wysylki (
      ID_Wysylki SERIAL PRIMARY KEY,
      ID_Zamowienia INTEGER NOT NULL,
      Firma_kurierska VARCHAR(100),
      Numer_listu VARCHAR(100),
      Status_paczki VARCHAR(50),

      CONSTRAINT fk_wysylki_zamowienia
         FOREIGN KEY (ID_Zamowienia)
         REFERENCES Zamowienia(ID_Zamowienia)
         ON DELETE CASCADE
   );

   -- =========================================
   -- TABELA: Opinie
   -- =========================================
   CREATE TABLE Opinie (
      ID_Opinii SERIAL PRIMARY KEY,
      ID_Zamowienia INTEGER NOT NULL,
      ID_Produktu INTEGER NOT NULL,
      Ocena SMALLINT NOT NULL CHECK (Ocena BETWEEN 1 AND 5),
      Komentarz TEXT,

      CONSTRAINT fk_opinie_pozycje
         FOREIGN KEY (ID_Zamowienia, ID_Produktu)
         REFERENCES Pozycje_Zamowienia(ID_Zamowienia, ID_Produktu)
         ON DELETE CASCADE
   );

   -- =========================================
   -- INDEKSY
   -- =========================================

   CREATE INDEX idx_produkty_kategoria
   ON Produkty(ID_Kategorii);

   CREATE INDEX idx_produkty_producent
   ON Produkty(ID_Producenta);

   CREATE INDEX idx_zamowienia_klient
   ON Zamowienia(ID_Klienta);

   CREATE INDEX idx_pozycje_produkt
   ON Pozycje_Zamowienia(ID_Produktu);

   CREATE INDEX idx_platnosci_zamowienie
   ON Platnosci(ID_Zamowienia);

   CREATE INDEX idx_wysylki_zamowienie
   ON Wysylki(ID_Zamowienia);

Reprezentacja bazy danych w pgadmin na zdalnym serwerze:

.. figure:: dowod_ze_zdalnego_postgres.png
   :align: center
   :alt: Zrzut ekranu z pgAdmin przedstawiający strukturę bazy danych

   Rysunek 5: Struktura bazy danych w pgAdmin.

Reprezentacja bazy danych w psql na lokalnym serwerze:

.. figure:: dowod_z_lokalnego_serwera.png
   :align: center
   :alt: Zrzut ekranu z pgAdmin przedstawiający strukturę bazy danych

   Rysunek 6: Struktura bazy danych w pgAdmin.


Wariant SQLite
--------------

Wariant SQLite zachowuje ten sam układ tabel i relacji, ale został dostosowany do silnika plikowego.
Zamiast typu ``SERIAL`` zastosowano ``INTEGER PRIMARY KEY AUTOINCREMENT``, a część typów, takich jak napisy i kwoty, została zapisana przy użyciu typów ``TEXT`` oraz ``REAL``.
W SQLite obsługa kluczy obcych wymaga włączenia mechanizmu ``PRAGMA foreign_keys = ON``, dlatego polecenie to znajduje się na początku skryptu tworzącego strukturę.
Ten wariant jest prostszy do uruchomienia lokalnie, ponieważ baza jest pojedynczym plikiem, natomiast PostgreSQL lepiej nadaje się do pracy wieloużytkownikowej i wdrożeń serwerowych.

Kod dla SQLite3::

    -- =========================================
    -- TWORZENIE TABEL - SKLEP INTERNETOWY
    -- SQLite
    -- =========================================

    PRAGMA foreign_keys = ON;

    -- Usuwanie tabel jeśli istnieją
    DROP TABLE IF EXISTS Opinie;
    DROP TABLE IF EXISTS Wysylki;
    DROP TABLE IF EXISTS Platnosci;
    DROP TABLE IF EXISTS Pozycje_Zamowienia;
    DROP TABLE IF EXISTS Zamowienia;
    DROP TABLE IF EXISTS Produkty;
    DROP TABLE IF EXISTS Kody_Rabatowe;
    DROP TABLE IF EXISTS Kategorie;
    DROP TABLE IF EXISTS Producenci;
    DROP TABLE IF EXISTS Klienci;

    -- =========================================
    -- TABELA: Klienci
    -- =========================================
    CREATE TABLE Klienci (
        ID_Klienta INTEGER PRIMARY KEY AUTOINCREMENT,
        Imie TEXT NOT NULL,
        Nazwisko TEXT NOT NULL,
        Email TEXT UNIQUE NOT NULL,
        Telefon TEXT,
        Miasto TEXT,
        Ulica TEXT,
        Kod_Pocztowy TEXT
    );

    -- =========================================
    -- TABELA: Kategorie
    -- =========================================
    CREATE TABLE Kategorie (
        ID_Kategorii INTEGER PRIMARY KEY AUTOINCREMENT,
        Nazwa_kategorii TEXT NOT NULL
    );

    -- =========================================
    -- TABELA: Producenci
    -- =========================================
    CREATE TABLE Producenci (
        ID_Producenta INTEGER PRIMARY KEY AUTOINCREMENT,
        Nazwa_producenta TEXT NOT NULL,
        Kraj_pochodzenia TEXT
    );

    -- =========================================
    -- TABELA: Kody_Rabatowe
    -- =========================================
    CREATE TABLE Kody_Rabatowe (
        ID_Kodu INTEGER PRIMARY KEY AUTOINCREMENT,
        Kod_tekstowy TEXT UNIQUE NOT NULL,
        Znizka_procentowa INTEGER
            CHECK (Znizka_procentowa BETWEEN 0 AND 100)
    );

    -- =========================================
    -- TABELA: Produkty
    -- =========================================
    CREATE TABLE Produkty (
        ID_Produktu INTEGER PRIMARY KEY AUTOINCREMENT,
        ID_Kategorii INTEGER,
        ID_Producenta INTEGER,
        Nazwa TEXT NOT NULL,
        Opis TEXT,
        Cena_aktualna REAL NOT NULL
            CHECK (Cena_aktualna >= 0),
        Stan_magazynowy INTEGER NOT NULL DEFAULT 0
            CHECK (Stan_magazynowy >= 0),

        FOREIGN KEY (ID_Kategorii)
            REFERENCES Kategorie(ID_Kategorii)
            ON DELETE SET NULL,

        FOREIGN KEY (ID_Producenta)
            REFERENCES Producenci(ID_Producenta)
            ON DELETE SET NULL
    );

    -- =========================================
    -- TABELA: Zamowienia
    -- =========================================
    CREATE TABLE Zamowienia (
        ID_Zamowienia INTEGER PRIMARY KEY AUTOINCREMENT,
        ID_Klienta INTEGER NOT NULL,
        ID_Kodu INTEGER,
        Data_zamowienia DATETIME DEFAULT CURRENT_TIMESTAMP,
        Status_zamowienia TEXT NOT NULL,

        FOREIGN KEY (ID_Klienta)
            REFERENCES Klienci(ID_Klienta)
            ON DELETE CASCADE,

        FOREIGN KEY (ID_Kodu)
            REFERENCES Kody_Rabatowe(ID_Kodu)
            ON DELETE SET NULL
    );

    -- =========================================
    -- TABELA: Platnosci
    -- =========================================
    CREATE TABLE Platnosci (
        ID_Platnosci INTEGER PRIMARY KEY AUTOINCREMENT,
        ID_Zamowienia INTEGER NOT NULL,
        Metoda_platnosci TEXT NOT NULL,
        Status_platnosci TEXT NOT NULL,

        FOREIGN KEY (ID_Zamowienia)
            REFERENCES Zamowienia(ID_Zamowienia)
            ON DELETE CASCADE
    );

    -- =========================================
    -- TABELA: Pozycje_Zamowienia
    -- =========================================
    CREATE TABLE Pozycje_Zamowienia (
        ID_Zamowienia INTEGER NOT NULL,
        ID_Produktu INTEGER NOT NULL,
        Ilosc INTEGER NOT NULL
            CHECK (Ilosc > 0),
        Cena_historyczna REAL NOT NULL
            CHECK (Cena_historyczna >= 0),

        PRIMARY KEY (ID_Zamowienia, ID_Produktu),

        FOREIGN KEY (ID_Zamowienia)
            REFERENCES Zamowienia(ID_Zamowienia)
            ON DELETE CASCADE,

        FOREIGN KEY (ID_Produktu)
            REFERENCES Produkty(ID_Produktu)
            ON DELETE CASCADE
    );

    -- =========================================
    -- TABELA: Wysylki
    -- =========================================
    CREATE TABLE Wysylki (
        ID_Wysylki INTEGER PRIMARY KEY AUTOINCREMENT,
        ID_Zamowienia INTEGER NOT NULL,
        Firma_kurierska TEXT,
        Numer_listu TEXT,
        Status_paczki TEXT,

        FOREIGN KEY (ID_Zamowienia)
            REFERENCES Zamowienia(ID_Zamowienia)
            ON DELETE CASCADE
    );

    -- =========================================
    -- TABELA: Opinie
    -- =========================================
    CREATE TABLE Opinie (
        ID_Opinii INTEGER PRIMARY KEY AUTOINCREMENT,
        ID_Zamowienia INTEGER NOT NULL,
        ID_Produktu INTEGER NOT NULL,
        Ocena INTEGER NOT NULL
            CHECK (Ocena BETWEEN 1 AND 5),
        Komentarz TEXT,

        FOREIGN KEY (ID_Zamowienia, ID_Produktu)
            REFERENCES Pozycje_Zamowienia(ID_Zamowienia, ID_Produktu)
            ON DELETE CASCADE
    );

    -- =========================================
    -- INDEKSY
    -- =========================================

    CREATE INDEX idx_produkty_kategoria
    ON Produkty(ID_Kategorii);

    CREATE INDEX idx_produkty_producent
    ON Produkty(ID_Producenta);

    CREATE INDEX idx_zamowienia_klient
    ON Zamowienia(ID_Klienta);

    CREATE INDEX idx_pozycje_produkt
    ON Pozycje_Zamowienia(ID_Produktu);

    CREATE INDEX idx_platnosci_zamowienie
    ON Platnosci(ID_Zamowienia);

    CREATE INDEX idx_wysylki_zamowienie
    ON Wysylki(ID_Zamowienia);

Reprezentacja bazy danych w sqlite:

.. figure:: dowod_z_sqlite.png
   :align: center
   :alt: Zrzut ekranu reprezentacji sqlite z jupyterhub

   Rysunek 6: Lista tabel stworzonych sqlite w jupyterhub.


2. Skrypt do wprowadzania danych do bazy danych
===============================================


W tej części przedstawiono skrypty odpowiedzialne za załadowanie danych do wcześniej zdefiniowanych struktur.
Źródłem danych jest plik ``dane_plaskie.csv`` rozdzielany średnikiem.
Skrypt nie kopiuje danych bezpośrednio do jednej tabeli, tylko przekształca dane wejściowe do postaci relacyjnej: z jednego wiersza CSV wyodrębnia informacje o kliencie, produkcie, producencie, kategorii, zamówieniu, płatności, wysyłce, pozycji zamówienia oraz opinii.

Import ma charakter wsadowy, ponieważ cały plik CSV jest przetwarzany w jednym uruchomieniu programu.
Jednocześnie każdy rekord wejściowy jest obsługiwany kontrolowanie: przed dodaniem danych sprawdzane jest istnienie rekordów powiązanych, wyznaczane są brakujące identyfikatory i wykonywana jest walidacja wartości liczbowych.


Mechanizm importu dla PostgreSQL
--------------------------------

W wariancie PostgreSQL do połączenia z bazą wykorzystano bibliotekę ``SQLAlchemy`` wraz ze sterownikiem ``psycopg``.
Dane dostępowe są pobierane z pliku ``database_creds.json``, dzięki czemu hasło i nazwa użytkownika nie są wpisane na stałe w kodzie programu.
Zapytania wykonywane są parametrycznie, co ogranicza ryzyko błędów związanych ze znakami specjalnymi i oddziela treść polecenia SQL od wartości pobranych z pliku CSV.

Do PostgreSQL::

    import csv
    import simplejson
    from sqlalchemy import create_engine, text


    # ============================================================
    # KONFIGURACJA
    # ============================================================

    SCIEZKA_CSV = "dane_plaskie.csv"
    SEPARATOR = ";"
    SCIEZKA_CREDS = "./database_creds.json"


    # ============================================================
    # POŁĄCZENIE Z POSTGRESQL
    # ============================================================

    with open(SCIEZKA_CREDS, encoding="utf-8") as db_con_file:
        creds = simplejson.loads(db_con_file.read())

    connection_string = (
        "postgresql+psycopg://"
        + creds["user_name"]
        + ":"
        + creds["password"]
        + "@"
        + creds["host_name"]
        + ":"
        + creds["port_number"]
        + "/"
        + creds["db_name"]
    )

    dbEngine = create_engine(connection_string)


    # ============================================================
    # FUNKCJE POMOCNICZE
    # ============================================================

    def puste(x):
        return x is None or str(x).strip() == "" or str(x).strip().lower() == "nan"


    def wartosc(row, nazwa, domyslna=None):
        x = row.get(nazwa, domyslna)
        if puste(x):
            return domyslna
        return str(x).strip()


    def liczba(row, nazwa, domyslna=None):
        x = wartosc(row, nazwa, domyslna)
        if x is None:
            return None
        return int(float(str(x).replace(",", ".")))


    def kwota(row, nazwa, domyslna=None):
        x = wartosc(row, nazwa, domyslna)
        if x is None:
            return None
        return float(str(x).replace(",", "."))


    def istnieje(connection, tabela, warunek):
        warunki = [f"{k.lower()} = :{k}" for k in warunek.keys()]

        polecenie = f"""
        SELECT 1
        FROM {tabela.lower()}
        WHERE {" AND ".join(warunki)}
        LIMIT 1
        """

        wynik = connection.execute(text(polecenie), warunek).first()
        return wynik is not None


    def pobierz_id(connection, tabela, kolumna_id, warunek):
        warunki = [f"{k.lower()} = :{k}" for k in warunek.keys()]

        polecenie = f"""
        SELECT {kolumna_id.lower()}
        FROM {tabela.lower()}
        WHERE {" AND ".join(warunki)}
        LIMIT 1
        """

        wynik = connection.execute(text(polecenie), warunek).first()

        if wynik:
            return wynik[0]

        return None


    def next_id(connection, tabela, kolumna_id):
        polecenie = f"""
        SELECT COALESCE(MAX({kolumna_id.lower()}), 0) + 1
        FROM {tabela.lower()}
        """

        return connection.execute(text(polecenie)).scalar()


    def insert(connection, tabela, dane):
        dane = {k: v for k, v in dane.items() if v is not None}

        if not dane:
            return

        kolumny = ", ".join([k.lower() for k in dane.keys()])
        parametry = ", ".join([f":{k}" for k in dane.keys()])

        polecenie = f"""
        INSERT INTO {tabela.lower()} ({kolumny})
        VALUES ({parametry})
        """

        connection.execute(text(polecenie), dane)


    # ============================================================
    # IMPORT JEDNEGO WIERSZA
    # ============================================================

    def importuj_wiersz(connection, row):
        # Pominięcie przypadkowo wklejonego nagłówka w środku pliku
        if wartosc(row, "ID_Klienta") == "ID_Klienta":
            return "Pominięto powtórzony nagłówek"

        # ========================================================
        # KLIENCI
        # ========================================================

        id_klienta = liczba(row, "ID_Klienta")

        if id_klienta is None and wartosc(row, "Email") is not None:
            id_klienta = pobierz_id(
                connection,
                "Klienci",
                "ID_Klienta",
                {"Email": wartosc(row, "Email")}
            )

        if id_klienta is None and wartosc(row, "Imie") is not None:
            id_klienta = next_id(connection, "Klienci", "ID_Klienta")

        if id_klienta is not None:
            if not istnieje(connection, "Klienci", {"ID_Klienta": id_klienta}):
                insert(connection, "Klienci", {
                    "ID_Klienta": id_klienta,
                    "Imie": wartosc(row, "Imie"),
                    "Nazwisko": wartosc(row, "Nazwisko"),
                    "Email": wartosc(row, "Email"),
                    "Telefon": wartosc(row, "Telefon"),
                    "Miasto": wartosc(row, "Miasto"),
                    "Ulica": wartosc(row, "Ulica"),
                    "Kod_Pocztowy": wartosc(row, "Kod_Pocztowy"),
                })

        # ========================================================
        # KATEGORIE
        # ========================================================

        id_kategorii = liczba(row, "ID_Kategorii")

        if id_kategorii is None and wartosc(row, "Kategoria") is not None:
            id_kategorii = pobierz_id(
                connection,
                "Kategorie",
                "ID_Kategorii",
                {"Nazwa_kategorii": wartosc(row, "Kategoria")}
            )

        if id_kategorii is None and wartosc(row, "Kategoria") is not None:
            id_kategorii = next_id(connection, "Kategorie", "ID_Kategorii")

        if id_kategorii is not None:
            if not istnieje(connection, "Kategorie", {"ID_Kategorii": id_kategorii}):
                insert(connection, "Kategorie", {
                    "ID_Kategorii": id_kategorii,
                    "Nazwa_kategorii": wartosc(row, "Kategoria"),
                })

        # ========================================================
        # PRODUCENCI
        # ========================================================

        id_producenta = liczba(row, "ID_Producenta")

        if id_producenta is None and wartosc(row, "Producent") is not None:
            id_producenta = pobierz_id(
                connection,
                "Producenci",
                "ID_Producenta",
                {"Nazwa_producenta": wartosc(row, "Producent")}
            )

        if id_producenta is None and wartosc(row, "Producent") is not None:
            id_producenta = next_id(connection, "Producenci", "ID_Producenta")

        if id_producenta is not None:
            if not istnieje(connection, "Producenci", {"ID_Producenta": id_producenta}):
                insert(connection, "Producenci", {
                    "ID_Producenta": id_producenta,
                    "Nazwa_producenta": wartosc(row, "Producent"),
                    "Kraj_pochodzenia": wartosc(row, "Kraj_Producenta"),
                })

        # ========================================================
        # KODY RABATOWE
        # ========================================================

        id_kodu = liczba(row, "ID_Kodu")

        if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
            id_kodu = pobierz_id(
                connection,
                "Kody_Rabatowe",
                "ID_Kodu",
                {"Kod_tekstowy": wartosc(row, "Kod_Rabatowy")}
            )

        if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
            id_kodu = next_id(connection, "Kody_Rabatowe", "ID_Kodu")

        if id_kodu is not None:
            znizka = liczba(row, "Znizka")

            if znizka is not None and (znizka < 0 or znizka > 100):
                raise ValueError("Zniżka procentowa musi być w zakresie od 0 do 100")

            if not istnieje(connection, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
                insert(connection, "Kody_Rabatowe", {
                    "ID_Kodu": id_kodu,
                    "Kod_tekstowy": wartosc(row, "Kod_Rabatowy"),
                    "Znizka_procentowa": znizka,
                })

        # ========================================================
        # PRODUKTY
        # ========================================================

        id_produktu = liczba(row, "ID_Produktu")

        if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
            id_produktu = pobierz_id(
                connection,
                "Produkty",
                "ID_Produktu",
                {"Nazwa": wartosc(row, "Nazwa_Produktu")}
            )

        if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
            id_produktu = next_id(connection, "Produkty", "ID_Produktu")

        if id_produktu is not None:
            if id_kategorii is None:
                raise ValueError("Produkt nie ma kategorii")

            if id_producenta is None:
                raise ValueError("Produkt nie ma producenta")

            if not istnieje(connection, "Kategorie", {"ID_Kategorii": id_kategorii}):
                raise ValueError("Nie można dodać produktu, bo kategoria nie istnieje")

            if not istnieje(connection, "Producenci", {"ID_Producenta": id_producenta}):
                raise ValueError("Nie można dodać produktu, bo producent nie istnieje")

            cena = kwota(row, "Cena_Aktualna")
            stan = liczba(row, "Stan_Magazynowy")

            if cena is not None and cena < 0:
                raise ValueError("Cena aktualna nie może być ujemna")

            if stan is not None and stan < 0:
                raise ValueError("Stan magazynowy nie może być ujemny")

            if not istnieje(connection, "Produkty", {"ID_Produktu": id_produktu}):
                insert(connection, "Produkty", {
                    "ID_Produktu": id_produktu,
                    "ID_Kategorii": id_kategorii,
                    "ID_Producenta": id_producenta,
                    "Nazwa": wartosc(row, "Nazwa_Produktu"),
                    "Opis": wartosc(row, "Opis"),
                    "Cena_aktualna": cena,
                    "Stan_magazynowy": stan,
                })

        # ========================================================
        # ZAMÓWIENIA
        # ========================================================

        id_zamowienia = liczba(row, "ID_Zamowienia")

        if id_zamowienia is None and wartosc(row, "Data_Zamowienia") is not None:
            id_zamowienia = next_id(connection, "Zamowienia", "ID_Zamowienia")

        if id_zamowienia is not None:
            if id_klienta is None:
                raise ValueError("Zamówienie nie ma klienta")

            if not istnieje(connection, "Klienci", {"ID_Klienta": id_klienta}):
                raise ValueError("Nie można dodać zamówienia, bo klient nie istnieje")

            if id_kodu is not None and not istnieje(connection, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
                raise ValueError("Nie można dodać zamówienia, bo kod rabatowy nie istnieje")

            if not istnieje(connection, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                insert(connection, "Zamowienia", {
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Klienta": id_klienta,
                    "ID_Kodu": id_kodu,
                    "Data_zamowienia": wartosc(row, "Data_Zamowienia"),
                    "Status_zamowienia": wartosc(row, "Status_Zamowienia"),
                })

        # ========================================================
        # PŁATNOŚCI
        # ========================================================

        id_platnosci = liczba(row, "ID_Platnosci")

        if id_platnosci is None and wartosc(row, "Metoda_Platnosci") is not None:
            id_platnosci = next_id(connection, "Platnosci", "ID_Platnosci")

        if id_platnosci is not None:
            if id_zamowienia is None:
                raise ValueError("Płatność nie ma zamówienia")

            if not istnieje(connection, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać płatności, bo zamówienie nie istnieje")

            if not istnieje(connection, "Platnosci", {"ID_Platnosci": id_platnosci}):
                insert(connection, "Platnosci", {
                    "ID_Platnosci": id_platnosci,
                    "ID_Zamowienia": id_zamowienia,
                    "Metoda_platnosci": wartosc(row, "Metoda_Platnosci"),
                    "Status_platnosci": wartosc(row, "Status_Platnosci"),
                })

        # ========================================================
        # WYSYŁKI
        # ========================================================

        id_wysylki = liczba(row, "ID_Wysylki")

        if id_wysylki is None and wartosc(row, "Firma_Kurierska") is not None:
            id_wysylki = next_id(connection, "Wysylki", "ID_Wysylki")

        if id_wysylki is not None:
            if id_zamowienia is None:
                raise ValueError("Wysyłka nie ma zamówienia")

            if not istnieje(connection, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać wysyłki, bo zamówienie nie istnieje")

            if not istnieje(connection, "Wysylki", {"ID_Wysylki": id_wysylki}):
                insert(connection, "Wysylki", {
                    "ID_Wysylki": id_wysylki,
                    "ID_Zamowienia": id_zamowienia,
                    "Firma_kurierska": wartosc(row, "Firma_Kurierska"),
                    "Numer_listu": wartosc(row, "Numer_Listu"),
                    "Status_paczki": wartosc(row, "Status_Paczki"),
                })

        # ========================================================
        # POZYCJE ZAMÓWIENIA
        # ========================================================

        if id_zamowienia is not None and id_produktu is not None and wartosc(row, "Ilosc_Zakupiona") is not None:
            ilosc = liczba(row, "Ilosc_Zakupiona")
            cena_historyczna = kwota(row, "Cena_Historyczna")

            if ilosc <= 0:
                raise ValueError("Ilość w pozycji zamówienia musi być większa od 0")

            if cena_historyczna is not None and cena_historyczna < 0:
                raise ValueError("Cena historyczna nie może być ujemna")

            if not istnieje(connection, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać pozycji, bo zamówienie nie istnieje")

            if not istnieje(connection, "Produkty", {"ID_Produktu": id_produktu}):
                raise ValueError("Nie można dodać pozycji, bo produkt nie istnieje")

            if not istnieje(connection, "Pozycje_Zamowienia", {
                "ID_Zamowienia": id_zamowienia,
                "ID_Produktu": id_produktu,
            }):
                insert(connection, "Pozycje_Zamowienia", {
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Produktu": id_produktu,
                    "Ilosc": ilosc,
                    "Cena_historyczna": cena_historyczna,
                })

        # ========================================================
        # OPINIE
        # ========================================================

        id_opinii = liczba(row, "ID_Opinii")

        if id_opinii is None and wartosc(row, "Ocena_Produktu") is not None:
            id_opinii = next_id(connection, "Opinie", "ID_Opinii")

        if id_opinii is not None:
            if id_zamowienia is None:
                raise ValueError("Opinia nie ma zamówienia")

            if id_produktu is None:
                raise ValueError("Opinia nie ma produktu")

            if not istnieje(connection, "Pozycje_Zamowienia", {
                "ID_Zamowienia": id_zamowienia,
                "ID_Produktu": id_produktu,
            }):
                raise ValueError("Nie można dodać opinii, bo nie istnieje taka pozycja zamówienia")

            ocena = liczba(row, "Ocena_Produktu")

            if ocena < 1 or ocena > 5:
                raise ValueError("Ocena musi być w zakresie od 1 do 5")

            if not istnieje(connection, "Opinie", {"ID_Opinii": id_opinii}):
                insert(connection, "Opinie", {
                    "ID_Opinii": id_opinii,
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Produktu": id_produktu,
                    "Ocena": ocena,
                    "Komentarz": wartosc(row, "Komentarz"),
                })

        return "OK"


    # ============================================================
    # GŁÓWNA FUNKCJA IMPORTU
    # ============================================================

    def importuj_csv_postgres(sciezka_csv=SCIEZKA_CSV, separator=SEPARATOR):
        licznik_ok = 0
        licznik_bledow = 0
        bledy = []

        with open(sciezka_csv, newline="", encoding="utf-8") as plik:
            reader = csv.DictReader(plik, delimiter=separator)

            with dbEngine.connect() as connection:
                for nr, row in enumerate(reader, start=2):
                    try:
                        wynik = importuj_wiersz(connection, row)

                        if wynik == "OK":
                            connection.commit()
                            licznik_ok += 1
                        else:
                            connection.rollback()
                            print(f"Wiersz {nr}: {wynik}")

                    except Exception as blad:
                        connection.rollback()
                        licznik_bledow += 1
                        komunikat = f"Błąd w wierszu {nr}: {blad}"
                        bledy.append(komunikat)
                        print(komunikat)

        print("=" * 80)
        print("IMPORT POSTGRESQL ZAKOŃCZONY")
        print("=" * 80)
        print("Poprawne wiersze:", licznik_ok)
        print("Błędne wiersze:", licznik_bledow)

        if bledy:
            print("\nLista błędów:")
            for blad in bledy:
                print("-", blad)


    # ============================================================
    # URUCHOMIENIE
    # ============================================================

    importuj_csv_postgres(SCIEZKA_CSV, SEPARATOR)



Mechanizm importu dla SQLite
----------------------------

W wariancie SQLite zastosowano standardową bibliotekę ``sqlite3``.
Jest to wystarczające rozwiązanie dla bazy plikowej, ponieważ nie wymaga konfiguracji serwera ani dodatkowego sterownika.
Zapytania również są wykonywane parametrycznie, ale z użyciem znaczników ``?``, zgodnych ze składnią biblioteki ``sqlite3``.
Logika importu pozostaje taka sama jak w PostgreSQL, dzięki czemu można porównać zachowanie obu silników na tym samym zestawie danych.

Do SQLITE::

    import csv
    import sqlite3


    # ============================================================
    # KONFIGURACJA
    # ============================================================

    SCIEZKA_BAZY = "sklep.db"
    SCIEZKA_CSV = "dane_plaskie.csv"
    SEPARATOR = ";"


    # ============================================================
    # FUNKCJE POMOCNICZE
    # ============================================================

    def puste(x):
        return x is None or str(x).strip() == "" or str(x).strip().lower() == "nan"


    def wartosc(row, nazwa, domyslna=None):
        x = row.get(nazwa, domyslna)
        if puste(x):
            return domyslna
        return str(x).strip()


    def liczba(row, nazwa, domyslna=None):
        x = wartosc(row, nazwa, domyslna)
        if x is None:
            return None
        return int(float(str(x).replace(",", ".")))


    def kwota(row, nazwa, domyslna=None):
        x = wartosc(row, nazwa, domyslna)
        if x is None:
            return None
        return float(str(x).replace(",", "."))


    def next_id(cursor, tabela, kolumna_id):
        polecenie = f'SELECT COALESCE(MAX("{kolumna_id}"), 0) + 1 FROM "{tabela}"'
        cursor.execute(polecenie)
        return cursor.fetchone()[0]


    def istnieje(cursor, tabela, warunek):
        kolumny = [f'"{k}" = ?' for k in warunek.keys()]
        wartosci = list(warunek.values())

        polecenie = f'''
        SELECT 1
        FROM "{tabela}"
        WHERE {" AND ".join(kolumny)}
        LIMIT 1
        '''

        cursor.execute(polecenie, wartosci)
        return cursor.fetchone() is not None


    def pobierz_id(cursor, tabela, kolumna_id, warunek):
        kolumny = [f'"{k}" = ?' for k in warunek.keys()]
        wartosci = list(warunek.values())

        polecenie = f'''
        SELECT "{kolumna_id}"
        FROM "{tabela}"
        WHERE {" AND ".join(kolumny)}
        LIMIT 1
        '''

        cursor.execute(polecenie, wartosci)
        wynik = cursor.fetchone()

        if wynik:
            return wynik[0]

        return None


    def insert(cursor, tabela, dane):
        dane = {k: v for k, v in dane.items() if v is not None}

        if not dane:
            return

        kolumny = ", ".join([f'"{k}"' for k in dane.keys()])
        znaki = ", ".join(["?" for _ in dane.keys()])
        wartosci = list(dane.values())

        polecenie = f'''
        INSERT INTO "{tabela}" ({kolumny})
        VALUES ({znaki})
        '''

        cursor.execute(polecenie, wartosci)


    # ============================================================
    # IMPORT JEDNEGO WIERSZA
    # ============================================================

    def importuj_wiersz(cursor, row):
        # Pominięcie przypadkowo wklejonego nagłówka w środku pliku
        if wartosc(row, "ID_Klienta") == "ID_Klienta":
            return "Pominięto powtórzony nagłówek"

        # ========================================================
        # KLIENCI
        # ========================================================

        id_klienta = liczba(row, "ID_Klienta")

        if id_klienta is None and wartosc(row, "Email") is not None:
            id_klienta = pobierz_id(
                cursor,
                "Klienci",
                "ID_Klienta",
                {"Email": wartosc(row, "Email")}
            )

        if id_klienta is None and wartosc(row, "Imie") is not None:
            id_klienta = next_id(cursor, "Klienci", "ID_Klienta")

        if id_klienta is not None:
            if not istnieje(cursor, "Klienci", {"ID_Klienta": id_klienta}):
                insert(cursor, "Klienci", {
                    "ID_Klienta": id_klienta,
                    "Imie": wartosc(row, "Imie"),
                    "Nazwisko": wartosc(row, "Nazwisko"),
                    "Email": wartosc(row, "Email"),
                    "Telefon": wartosc(row, "Telefon"),
                    "Miasto": wartosc(row, "Miasto"),
                    "Ulica": wartosc(row, "Ulica"),
                    "Kod_Pocztowy": wartosc(row, "Kod_Pocztowy"),
                })

        # ========================================================
        # KATEGORIE
        # ========================================================

        id_kategorii = liczba(row, "ID_Kategorii")

        if id_kategorii is None and wartosc(row, "Kategoria") is not None:
            id_kategorii = pobierz_id(
                cursor,
                "Kategorie",
                "ID_Kategorii",
                {"Nazwa_kategorii": wartosc(row, "Kategoria")}
            )

        if id_kategorii is None and wartosc(row, "Kategoria") is not None:
            id_kategorii = next_id(cursor, "Kategorie", "ID_Kategorii")

        if id_kategorii is not None:
            if not istnieje(cursor, "Kategorie", {"ID_Kategorii": id_kategorii}):
                insert(cursor, "Kategorie", {
                    "ID_Kategorii": id_kategorii,
                    "Nazwa_kategorii": wartosc(row, "Kategoria"),
                })

        # ========================================================
        # PRODUCENCI
        # ========================================================

        id_producenta = liczba(row, "ID_Producenta")

        if id_producenta is None and wartosc(row, "Producent") is not None:
            id_producenta = pobierz_id(
                cursor,
                "Producenci",
                "ID_Producenta",
                {"Nazwa_producenta": wartosc(row, "Producent")}
            )

        if id_producenta is None and wartosc(row, "Producent") is not None:
            id_producenta = next_id(cursor, "Producenci", "ID_Producenta")

        if id_producenta is not None:
            if not istnieje(cursor, "Producenci", {"ID_Producenta": id_producenta}):
                insert(cursor, "Producenci", {
                    "ID_Producenta": id_producenta,
                    "Nazwa_producenta": wartosc(row, "Producent"),
                    "Kraj_pochodzenia": wartosc(row, "Kraj_Producenta"),
                })

        # ========================================================
        # KODY RABATOWE
        # ========================================================

        id_kodu = liczba(row, "ID_Kodu")

        if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
            id_kodu = pobierz_id(
                cursor,
                "Kody_Rabatowe",
                "ID_Kodu",
                {"Kod_tekstowy": wartosc(row, "Kod_Rabatowy")}
            )

        if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
            id_kodu = next_id(cursor, "Kody_Rabatowe", "ID_Kodu")

        if id_kodu is not None:
            znizka = liczba(row, "Znizka")

            if znizka is not None and (znizka < 0 or znizka > 100):
                raise ValueError("Zniżka procentowa musi być w zakresie od 0 do 100")

            if not istnieje(cursor, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
                insert(cursor, "Kody_Rabatowe", {
                    "ID_Kodu": id_kodu,
                    "Kod_tekstowy": wartosc(row, "Kod_Rabatowy"),
                    "Znizka_procentowa": znizka,
                })

        # ========================================================
        # PRODUKTY
        # ========================================================

        id_produktu = liczba(row, "ID_Produktu")

        if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
            id_produktu = pobierz_id(
                cursor,
                "Produkty",
                "ID_Produktu",
                {"Nazwa": wartosc(row, "Nazwa_Produktu")}
            )

        if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
            id_produktu = next_id(cursor, "Produkty", "ID_Produktu")

        if id_produktu is not None:
            if id_kategorii is None:
                raise ValueError("Produkt nie ma kategorii")

            if id_producenta is None:
                raise ValueError("Produkt nie ma producenta")

            if not istnieje(cursor, "Kategorie", {"ID_Kategorii": id_kategorii}):
                raise ValueError("Nie można dodać produktu, bo kategoria nie istnieje")

            if not istnieje(cursor, "Producenci", {"ID_Producenta": id_producenta}):
                raise ValueError("Nie można dodać produktu, bo producent nie istnieje")

            cena = kwota(row, "Cena_Aktualna")
            stan = liczba(row, "Stan_Magazynowy")

            if cena is not None and cena < 0:
                raise ValueError("Cena aktualna nie może być ujemna")

            if stan is not None and stan < 0:
                raise ValueError("Stan magazynowy nie może być ujemny")

            if not istnieje(cursor, "Produkty", {"ID_Produktu": id_produktu}):
                insert(cursor, "Produkty", {
                    "ID_Produktu": id_produktu,
                    "ID_Kategorii": id_kategorii,
                    "ID_Producenta": id_producenta,
                    "Nazwa": wartosc(row, "Nazwa_Produktu"),
                    "Opis": wartosc(row, "Opis"),
                    "Cena_aktualna": cena,
                    "Stan_magazynowy": stan,
                })

        # ========================================================
        # ZAMÓWIENIA
        # ========================================================

        id_zamowienia = liczba(row, "ID_Zamowienia")

        if id_zamowienia is None and wartosc(row, "Data_Zamowienia") is not None:
            id_zamowienia = next_id(cursor, "Zamowienia", "ID_Zamowienia")

        if id_zamowienia is not None:
            if id_klienta is None:
                raise ValueError("Zamówienie nie ma klienta")

            if not istnieje(cursor, "Klienci", {"ID_Klienta": id_klienta}):
                raise ValueError("Nie można dodać zamówienia, bo klient nie istnieje")

            if id_kodu is not None and not istnieje(cursor, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
                raise ValueError("Nie można dodać zamówienia, bo kod rabatowy nie istnieje")

            if not istnieje(cursor, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                insert(cursor, "Zamowienia", {
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Klienta": id_klienta,
                    "ID_Kodu": id_kodu,
                    "Data_zamowienia": wartosc(row, "Data_Zamowienia"),
                    "Status_zamowienia": wartosc(row, "Status_Zamowienia"),
                })

        # ========================================================
        # PŁATNOŚCI
        # ========================================================

        id_platnosci = liczba(row, "ID_Platnosci")

        if id_platnosci is None and wartosc(row, "Metoda_Platnosci") is not None:
            id_platnosci = next_id(cursor, "Platnosci", "ID_Platnosci")

        if id_platnosci is not None:
            if id_zamowienia is None:
                raise ValueError("Płatność nie ma zamówienia")

            if not istnieje(cursor, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać płatności, bo zamówienie nie istnieje")

            if not istnieje(cursor, "Platnosci", {"ID_Platnosci": id_platnosci}):
                insert(cursor, "Platnosci", {
                    "ID_Platnosci": id_platnosci,
                    "ID_Zamowienia": id_zamowienia,
                    "Metoda_platnosci": wartosc(row, "Metoda_Platnosci"),
                    "Status_platnosci": wartosc(row, "Status_Platnosci"),
                })

        # ========================================================
        # WYSYŁKI
        # ========================================================

        id_wysylki = liczba(row, "ID_Wysylki")

        if id_wysylki is None and wartosc(row, "Firma_Kurierska") is not None:
            id_wysylki = next_id(cursor, "Wysylki", "ID_Wysylki")

        if id_wysylki is not None:
            if id_zamowienia is None:
                raise ValueError("Wysyłka nie ma zamówienia")

            if not istnieje(cursor, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać wysyłki, bo zamówienie nie istnieje")

            if not istnieje(cursor, "Wysylki", {"ID_Wysylki": id_wysylki}):
                insert(cursor, "Wysylki", {
                    "ID_Wysylki": id_wysylki,
                    "ID_Zamowienia": id_zamowienia,
                    "Firma_kurierska": wartosc(row, "Firma_Kurierska"),
                    "Numer_listu": wartosc(row, "Numer_Listu"),
                    "Status_paczki": wartosc(row, "Status_Paczki"),
                })

        # ========================================================
        # POZYCJE ZAMÓWIENIA
        # ========================================================

        if id_zamowienia is not None and id_produktu is not None and wartosc(row, "Ilosc_Zakupiona") is not None:
            ilosc = liczba(row, "Ilosc_Zakupiona")
            cena_historyczna = kwota(row, "Cena_Historyczna")

            if ilosc <= 0:
                raise ValueError("Ilość w pozycji zamówienia musi być większa od 0")

            if cena_historyczna is not None and cena_historyczna < 0:
                raise ValueError("Cena historyczna nie może być ujemna")

            if not istnieje(cursor, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
                raise ValueError("Nie można dodać pozycji, bo zamówienie nie istnieje")

            if not istnieje(cursor, "Produkty", {"ID_Produktu": id_produktu}):
                raise ValueError("Nie można dodać pozycji, bo produkt nie istnieje")

            if not istnieje(cursor, "Pozycje_Zamowienia", {
                "ID_Zamowienia": id_zamowienia,
                "ID_Produktu": id_produktu,
            }):
                insert(cursor, "Pozycje_Zamowienia", {
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Produktu": id_produktu,
                    "Ilosc": ilosc,
                    "Cena_historyczna": cena_historyczna,
                })

        # ========================================================
        # OPINIE
        # ========================================================

        id_opinii = liczba(row, "ID_Opinii")

        if id_opinii is None and wartosc(row, "Ocena_Produktu") is not None:
            id_opinii = next_id(cursor, "Opinie", "ID_Opinii")

        if id_opinii is not None:
            if id_zamowienia is None:
                raise ValueError("Opinia nie ma zamówienia")

            if id_produktu is None:
                raise ValueError("Opinia nie ma produktu")

            if not istnieje(cursor, "Pozycje_Zamowienia", {
                "ID_Zamowienia": id_zamowienia,
                "ID_Produktu": id_produktu,
            }):
                raise ValueError("Nie można dodać opinii, bo nie istnieje taka pozycja zamówienia")

            ocena = liczba(row, "Ocena_Produktu")

            if ocena < 1 or ocena > 5:
                raise ValueError("Ocena musi być w zakresie od 1 do 5")

            if not istnieje(cursor, "Opinie", {"ID_Opinii": id_opinii}):
                insert(cursor, "Opinie", {
                    "ID_Opinii": id_opinii,
                    "ID_Zamowienia": id_zamowienia,
                    "ID_Produktu": id_produktu,
                    "Ocena": ocena,
                    "Komentarz": wartosc(row, "Komentarz"),
                })

        return "OK"


    # ============================================================
    # GŁÓWNA FUNKCJA IMPORTU
    # ============================================================

    def importuj_csv_sqlite(sciezka_bazy=SCIEZKA_BAZY, sciezka_csv=SCIEZKA_CSV, separator=SEPARATOR):
        conn = sqlite3.connect(sciezka_bazy)
        cursor = conn.cursor()
        cursor.execute("PRAGMA foreign_keys = ON")

        licznik_ok = 0
        licznik_bledow = 0
        bledy = []

        with open(sciezka_csv, newline="", encoding="utf-8") as plik:
            reader = csv.DictReader(plik, delimiter=separator)

            for nr, row in enumerate(reader, start=2):
                try:
                    wynik = importuj_wiersz(cursor, row)

                    if wynik == "OK":
                        conn.commit()
                        licznik_ok += 1
                    else:
                        conn.rollback()
                        print(f"Wiersz {nr}: {wynik}")

                except Exception as blad:
                    conn.rollback()
                    licznik_bledow += 1
                    komunikat = f"Błąd w wierszu {nr}: {blad}"
                    bledy.append(komunikat)
                    print(komunikat)

        conn.close()

        print("=" * 80)
        print("IMPORT SQLITE ZAKOŃCZONY")
        print("=" * 80)
        print("Poprawne wiersze:", licznik_ok)
        print("Błędne wiersze:", licznik_bledow)

        if bledy:
            print("\nLista błędów:")
            for blad in bledy:
                print("-", blad)


    # ============================================================
    # URUCHOMIENIE
    # ============================================================

    importuj_csv_sqlite(SCIEZKA_BAZY, SCIEZKA_CSV, SEPARATOR)

3. Omówienie wyboru mechanizmów i komentarz do importu
======================================================

Dobór mechanizmu wsadowego wprowadzania danych
----------------------------------------------

Do importu danych wybrano przetwarzanie pliku CSV w języku Python, ponieważ dane wejściowe mają charakter płaski, a baza docelowa jest znormalizowana.
Proste użycie poleceń typu ``COPY`` w PostgreSQL albo ``.import`` w SQLite byłoby szybkie, ale w tym przypadku niewystarczające, ponieważ jeden wiersz źródłowy musi zostać rozdzielony na wiele tabel powiązanych relacjami.
Skrypt musi najpierw ustalić, czy istnieje już klient, producent, kategoria, produkt albo zamówienie, a dopiero później może dodać rekordy zależne, takie jak pozycja zamówienia, płatność, wysyłka i opinia.

Wybrany mechanizm jest kompromisem między prostotą a kontrolą poprawności danych.
Zamiast ładować dane bezpośrednio do tabel docelowych bez sprawdzania zależności, skrypt wykonuje import w sposób świadomy struktury relacyjnej.
Dzięki temu możliwe jest ponowne uruchomienie importu bez automatycznego dublowania rekordów o tych samych identyfikatorach lub tych samych kluczowych atrybutach, na przykład adresie e-mail klienta albo nazwie producenta.

W PostgreSQL użyto ``SQLAlchemy`` i parametryzowanych zapytań ``text()``, ponieważ takie podejście dobrze pasuje do aplikacyjnego ładowania danych i ułatwia przeniesienie konfiguracji połączenia poza kod.
W SQLite użyto biblioteki ``sqlite3``, ponieważ jest dostępna w standardowej instalacji Pythona i dobrze odpowiada charakterowi bazy plikowej.
W obu wariantach dane są czytane za pomocą ``csv.DictReader``, co pozwala odwoływać się do kolumn po nazwach zamiast po indeksach.

Przebieg procesu wprowadzania danych
------------------------------------

Proces importu można opisać w następującej kolejności:

1. Program otwiera plik CSV i odczytuje go wiersz po wierszu.
2. Dla każdego wiersza wykonywane jest czyszczenie wartości pustych oraz konwersja typów liczbowych.
3. Skrypt sprawdza, czy dany rekord już istnieje w tabeli docelowej.
4. Jeżeli identyfikator nie został podany w pliku, program próbuje odszukać istniejący rekord po atrybucie naturalnym, na przykład po e-mailu klienta albo nazwie kategorii.
5. Jeżeli rekord nadal nie istnieje, wyznaczany jest kolejny identyfikator i wykonywane jest polecenie ``INSERT``.
6. Dane są dodawane w kolejności zgodnej z zależnościami: najpierw tabele słownikowe i nadrzędne, później tabele zależne.
7. Przy błędzie wykonywany jest ``rollback``, dzięki czemu nie zostaje zapisany częściowo przetworzony wiersz.
8. Po zakończeniu działania skrypt wypisuje liczbę poprawnie zaimportowanych wierszy oraz listę błędów.

Takie podejście zwiększa bezpieczeństwo importu, ponieważ błąd w jednym wierszu nie musi przerywać całego procesu, a jednocześnie nie zostawia w bazie niespójnych danych.
Szczególnie ważne jest to przy tabelach zależnych, takich jak ``Pozycje_Zamowienia`` i ``Opinie``, gdzie rekord może zostać dodany dopiero wtedy, gdy istnieje odpowiednie zamówienie i produkt.

Kontrola poprawności i spójności danych
---------------------------------------

Kontrola poprawności odbywa się na dwóch poziomach.
Pierwszy poziom znajduje się w samej bazie danych: klucze główne zapewniają unikalność rekordów, klucze obce wymuszają istnienie rekordów nadrzędnych, a ograniczenia ``CHECK`` blokują wartości spoza dopuszczalnego zakresu, na przykład ujemną cenę, zerową ilość produktu albo ocenę spoza zakresu od 1 do 5.
Drugi poziom znajduje się w skrypcie importującym, który jeszcze przed wykonaniem polecenia ``INSERT`` sprawdza wartości liczbowe, puste pola oraz istnienie rekordów zależnych.

Dzięki temu baza nie jest traktowana wyłącznie jako miejsce przechowywania danych, ale również jako mechanizm pilnujący reguł biznesowych.
Skrypt aplikacyjny odpowiada za przygotowanie i uporządkowanie danych, natomiast system bazodanowy ostatecznie wymusza ograniczenia integralności.

Różnice między importem do PostgreSQL i SQLite
----------------------------------------------

Wariant PostgreSQL jest bardziej odpowiedni dla środowiska serwerowego, pracy wielu użytkowników i większych zbiorów danych.
Zapewnia silniejsze typowanie, rozbudowaną obsługę transakcji, sekwencje identyfikatorów oraz lepsze możliwości późniejszej optymalizacji importu, na przykład przez tabelę tymczasową, ``COPY`` albo import porcjami.

Wariant SQLite jest prostszy organizacyjnie, ponieważ cała baza znajduje się w jednym pliku.
Dobrze nadaje się do testów, prototypowania, ćwiczeń laboratoryjnych i niewielkich aplikacji lokalnych.
Wymaga jednak pamiętania o włączeniu obsługi kluczy obcych przez ``PRAGMA foreign_keys = ON`` dla każdego połączenia, jeżeli zależy nam na egzekwowaniu integralności referencyjnej także podczas importu.

Możliwe usprawnienia
--------------------

Przy małym lub średnim pliku CSV obecne rozwiązanie jest wystarczające i czytelne.
Dla dużych zbiorów danych można byłoby jednak rozważyć import dwuetapowy: najpierw szybkie wczytanie danych do tabeli tymczasowej, a następnie wykonanie zestawu zapytań ``INSERT INTO ... SELECT ...`` przenoszących dane do tabel docelowych.
W PostgreSQL można byłoby dodatkowo użyć polecenia ``COPY``, a w SQLite większych transakcji obejmujących wiele wierszy naraz.
Takie rozwiązania byłyby szybsze, ale mniej przejrzyste od obecnego skryptu i trudniejsze do omówienia na etapie demonstracji działania bazy.
