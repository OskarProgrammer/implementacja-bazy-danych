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
