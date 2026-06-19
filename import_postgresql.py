"""Wsadowy import danych sklepu internetowego z CSV do PostgreSQL."""

import csv

import simplejson
from sqlalchemy import create_engine, text


SCIEZKA_CSV = "dane_plaskie.csv"
SEPARATOR = ";"
SCIEZKA_CREDS = "./database_creds.json"


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
    warunki = [f"{k.lower()} = :{k}" for k in warunek]
    polecenie = f"""
    SELECT 1
    FROM {tabela.lower()}
    WHERE {" AND ".join(warunki)}
    LIMIT 1
    """
    return connection.execute(text(polecenie), warunek).first() is not None


def pobierz_id(connection, tabela, kolumna_id, warunek):
    warunki = [f"{k.lower()} = :{k}" for k in warunek]
    polecenie = f"""
    SELECT {kolumna_id.lower()}
    FROM {tabela.lower()}
    WHERE {" AND ".join(warunki)}
    LIMIT 1
    """
    wynik = connection.execute(text(polecenie), warunek).first()
    return wynik[0] if wynik else None


def next_id(connection, tabela, kolumna_id):
    """Synchronizuje sekwencję z tabelą i pobiera kolejny identyfikator."""
    tabela = tabela.lower()
    kolumna_id = kolumna_id.lower()

    connection.execute(text(f"""
        SELECT setval(
            pg_get_serial_sequence('{tabela}', '{kolumna_id}'),
            COALESCE(MAX({kolumna_id}), 1),
            MAX({kolumna_id}) IS NOT NULL
        )
        FROM {tabela}
    """))

    return connection.execute(text(f"""
        SELECT nextval(
            pg_get_serial_sequence('{tabela}', '{kolumna_id}')
        )
    """)).scalar()


def synchronizuj_sekwencje(connection):
    tabele = {
        "Klienci": "ID_Klienta",
        "Kategorie": "ID_Kategorii",
        "Producenci": "ID_Producenta",
        "Kody_Rabatowe": "ID_Kodu",
        "Produkty": "ID_Produktu",
        "Zamowienia": "ID_Zamowienia",
        "Platnosci": "ID_Platnosci",
        "Wysylki": "ID_Wysylki",
        "Opinie": "ID_Opinii",
    }

    for tabela, kolumna_id in tabele.items():
        tabela = tabela.lower()
        kolumna_id = kolumna_id.lower()
        connection.execute(text(f"""
            SELECT setval(
                pg_get_serial_sequence('{tabela}', '{kolumna_id}'),
                COALESCE(MAX({kolumna_id}), 1),
                MAX({kolumna_id}) IS NOT NULL
            )
            FROM {tabela}
        """))


def insert(connection, tabela, dane):
    dane = {k: v for k, v in dane.items() if v is not None}
    if not dane:
        return

    kolumny = ", ".join(k.lower() for k in dane)
    parametry = ", ".join(f":{k}" for k in dane)
    polecenie = f"""
    INSERT INTO {tabela.lower()} ({kolumny})
    VALUES ({parametry})
    """
    connection.execute(text(polecenie), dane)


def importuj_wiersz(connection, row):
    if wartosc(row, "ID_Zamowienia") == "ID_Zamowienia":
        return "Pominięto powtórzony nagłówek"

    id_klienta = liczba(row, "ID_Klienta")
    if id_klienta is None and wartosc(row, "Email") is not None:
        id_klienta = pobierz_id(
            connection, "Klienci", "ID_Klienta",
            {"Email": wartosc(row, "Email")}
        )
    if id_klienta is None and wartosc(row, "Imie") is not None:
        id_klienta = next_id(connection, "Klienci", "ID_Klienta")
    if id_klienta is not None and not istnieje(
        connection, "Klienci", {"ID_Klienta": id_klienta}
    ):
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

    id_kategorii = liczba(row, "ID_Kategorii")
    if id_kategorii is None and wartosc(row, "Kategoria") is not None:
        id_kategorii = pobierz_id(
            connection, "Kategorie", "ID_Kategorii",
            {"Nazwa_kategorii": wartosc(row, "Kategoria")}
        )
    if id_kategorii is None and wartosc(row, "Kategoria") is not None:
        id_kategorii = next_id(connection, "Kategorie", "ID_Kategorii")
    if id_kategorii is not None and not istnieje(
        connection, "Kategorie", {"ID_Kategorii": id_kategorii}
    ):
        insert(connection, "Kategorie", {
            "ID_Kategorii": id_kategorii,
            "Nazwa_kategorii": wartosc(row, "Kategoria"),
        })

    id_producenta = liczba(row, "ID_Producenta")
    if id_producenta is None and wartosc(row, "Producent") is not None:
        id_producenta = pobierz_id(
            connection, "Producenci", "ID_Producenta",
            {"Nazwa_producenta": wartosc(row, "Producent")}
        )
    if id_producenta is None and wartosc(row, "Producent") is not None:
        id_producenta = next_id(connection, "Producenci", "ID_Producenta")
    if id_producenta is not None and not istnieje(
        connection, "Producenci", {"ID_Producenta": id_producenta}
    ):
        insert(connection, "Producenci", {
            "ID_Producenta": id_producenta,
            "Nazwa_producenta": wartosc(row, "Producent"),
            "Kraj_pochodzenia": wartosc(row, "Kraj_Producenta"),
        })

    id_kodu = liczba(row, "ID_Kodu")
    if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
        id_kodu = pobierz_id(
            connection, "Kody_Rabatowe", "ID_Kodu",
            {"Kod_tekstowy": wartosc(row, "Kod_Rabatowy")}
        )
    if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
        id_kodu = next_id(connection, "Kody_Rabatowe", "ID_Kodu")
    if id_kodu is not None:
        znizka = liczba(row, "Znizka")
        if znizka is not None and not 0 <= znizka <= 100:
            raise ValueError("Zniżka procentowa musi być w zakresie od 0 do 100")
        if not istnieje(connection, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
            insert(connection, "Kody_Rabatowe", {
                "ID_Kodu": id_kodu,
                "Kod_tekstowy": wartosc(row, "Kod_Rabatowy"),
                "Znizka_procentowa": znizka,
            })

    id_produktu = liczba(row, "ID_Produktu")
    if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
        id_produktu = pobierz_id(
            connection, "Produkty", "ID_Produktu",
            {"Nazwa": wartosc(row, "Nazwa_Produktu")}
        )
    if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
        id_produktu = next_id(connection, "Produkty", "ID_Produktu")
    if id_produktu is not None:
        if id_kategorii is None or id_producenta is None:
            raise ValueError("Produkt musi mieć kategorię i producenta")
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

    id_zamowienia = liczba(row, "ID_Zamowienia")
    if id_zamowienia is None:
        raise ValueError(
            "Brak ID_Zamowienia. Wszystkie pozycje tego samego "
            "zamówienia muszą mieć wspólny identyfikator."
        )
    if id_klienta is None:
        raise ValueError("Zamówienie nie ma klienta")
    if not istnieje(connection, "Zamowienia", {"ID_Zamowienia": id_zamowienia}):
        insert(connection, "Zamowienia", {
            "ID_Zamowienia": id_zamowienia,
            "ID_Klienta": id_klienta,
            "ID_Kodu": id_kodu,
            "Data_zamowienia": wartosc(row, "Data_Zamowienia"),
            "Status_zamowienia": wartosc(row, "Status_Zamowienia"),
        })

    if wartosc(row, "Metoda_Platnosci") is not None:
        id_platnosci = liczba(row, "ID_Platnosci")
        if id_platnosci is None:
            id_platnosci = pobierz_id(
                connection, "Platnosci", "ID_Platnosci",
                {"ID_Zamowienia": id_zamowienia}
            )
        if id_platnosci is None:
            id_platnosci = next_id(connection, "Platnosci", "ID_Platnosci")
        if not istnieje(
            connection, "Platnosci", {"ID_Zamowienia": id_zamowienia}
        ):
            insert(connection, "Platnosci", {
                "ID_Platnosci": id_platnosci,
                "ID_Zamowienia": id_zamowienia,
                "Metoda_platnosci": wartosc(row, "Metoda_Platnosci"),
                "Status_platnosci": wartosc(row, "Status_Platnosci"),
            })

    if wartosc(row, "Firma_Kurierska") is not None:
        id_wysylki = liczba(row, "ID_Wysylki")
        if id_wysylki is None:
            id_wysylki = pobierz_id(
                connection, "Wysylki", "ID_Wysylki",
                {"ID_Zamowienia": id_zamowienia}
            )
        if id_wysylki is None:
            id_wysylki = next_id(connection, "Wysylki", "ID_Wysylki")
        if not istnieje(
            connection, "Wysylki", {"ID_Zamowienia": id_zamowienia}
        ):
            insert(connection, "Wysylki", {
                "ID_Wysylki": id_wysylki,
                "ID_Zamowienia": id_zamowienia,
                "Firma_kurierska": wartosc(row, "Firma_Kurierska"),
                "Numer_listu": wartosc(row, "Numer_Listu"),
                "Status_paczki": wartosc(row, "Status_Paczki"),
            })

    if id_produktu is not None and wartosc(row, "Ilosc_Zakupiona") is not None:
        ilosc = liczba(row, "Ilosc_Zakupiona")
        cena_historyczna = kwota(row, "Cena_Historyczna")
        if ilosc is None or ilosc <= 0:
            raise ValueError("Ilość w pozycji zamówienia musi być większa od 0")
        if cena_historyczna is None or cena_historyczna < 0:
            raise ValueError("Cena historyczna musi być nieujemna")
        warunek_pozycji = {
            "ID_Zamowienia": id_zamowienia,
            "ID_Produktu": id_produktu,
        }
        if not istnieje(connection, "Pozycje_Zamowienia", warunek_pozycji):
            insert(connection, "Pozycje_Zamowienia", {
                **warunek_pozycji,
                "Ilosc": ilosc,
                "Cena_historyczna": cena_historyczna,
            })

    if wartosc(row, "Ocena_Produktu") is not None:
        warunek_opinii = {
            "ID_Zamowienia": id_zamowienia,
            "ID_Produktu": id_produktu,
        }
        if not istnieje(connection, "Pozycje_Zamowienia", warunek_opinii):
            raise ValueError(
                "Nie można dodać opinii, bo nie istnieje taka pozycja zamówienia"
            )
        ocena = liczba(row, "Ocena_Produktu")
        if ocena is None or not 1 <= ocena <= 5:
            raise ValueError("Ocena musi być w zakresie od 1 do 5")
        id_opinii = liczba(row, "ID_Opinii")
        if id_opinii is None:
            id_opinii = pobierz_id(
                connection, "Opinie", "ID_Opinii", warunek_opinii
            )
        if id_opinii is None:
            id_opinii = next_id(connection, "Opinie", "ID_Opinii")
        if not istnieje(connection, "Opinie", warunek_opinii):
            insert(connection, "Opinie", {
                "ID_Opinii": id_opinii,
                **warunek_opinii,
                "Ocena": ocena,
                "Komentarz": wartosc(row, "Komentarz"),
            })

    return "OK"


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

            synchronizuj_sekwencje(connection)
            connection.commit()

    print("=" * 80)
    print("IMPORT POSTGRESQL ZAKOŃCZONY")
    print("=" * 80)
    print("Poprawne wiersze:", licznik_ok)
    print("Błędne wiersze:", licznik_bledow)

    if bledy:
        print("\nLista błędów:")
        for blad in bledy:
            print("-", blad)


if __name__ == "__main__":
    importuj_csv_postgres(SCIEZKA_CSV, SEPARATOR)
