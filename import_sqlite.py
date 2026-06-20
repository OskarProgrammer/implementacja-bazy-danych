"""Wsadowy import danych sklepu internetowego z CSV do SQLite."""

import csv
import sqlite3
from collections import OrderedDict


SCIEZKA_BAZY = "sklep.db"
SCIEZKA_CSV = "dane_plaskie.csv"
SEPARATOR = ";"

STATUSY_ZAMOWIENIA = {"Nowe", "Opłacone", "Wysłane", "Dostarczone", "Anulowane"}
STATUSY_PLATNOSCI = {"Oczekująca", "Zakończona", "Odrzucona"}
STATUSY_PACZKI = {"Przygotowywana", "Nadana", "W transporcie", "Doręczona", "Zwrócona"}


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
    kolumny = [f'"{k}" = ?' for k in warunek]
    polecenie = f'''
    SELECT 1
    FROM "{tabela}"
    WHERE {" AND ".join(kolumny)}
    LIMIT 1
    '''
    cursor.execute(polecenie, list(warunek.values()))
    return cursor.fetchone() is not None


def pobierz_id(cursor, tabela, kolumna_id, warunek):
    kolumny = [f'"{k}" = ?' for k in warunek]
    polecenie = f'''
    SELECT "{kolumna_id}"
    FROM "{tabela}"
    WHERE {" AND ".join(kolumny)}
    LIMIT 1
    '''
    cursor.execute(polecenie, list(warunek.values()))
    wynik = cursor.fetchone()
    return wynik[0] if wynik else None


def insert(cursor, tabela, dane):
    dane = {k: v for k, v in dane.items() if v is not None}
    if not dane:
        return

    kolumny = ", ".join(f'"{k}"' for k in dane)
    znaki = ", ".join("?" for _ in dane)
    polecenie = f'''
    INSERT INTO "{tabela}" ({kolumny})
    VALUES ({znaki})
    '''
    cursor.execute(polecenie, list(dane.values()))


def sprawdz_zgodnosc(cursor, tabela, kolumna_id, identyfikator, dane):
    """Zgłasza błąd, gdy istniejący rekord ma inne dane niż w CSV."""
    kolumny = ", ".join(f'"{kolumna}"' for kolumna in dane)
    cursor.execute(
        f'SELECT {kolumny} FROM "{tabela}" WHERE "{kolumna_id}" = ?',
        (identyfikator,),
    )
    rekord = cursor.fetchone()
    if rekord is not None and tuple(rekord) != tuple(dane.values()):
        raise ValueError(f"Niespójne dane istniejącego rekordu w tabeli {tabela}")


def sprawdz_zgodnosc_warunku(cursor, tabela, warunek, dane):
    """Zgłasza błąd, gdy rekord wskazany warunkiem ma inne dane niż w CSV."""
    kolumny = ", ".join(f'"{kolumna}"' for kolumna in dane)
    warunki = " AND ".join(f'"{kolumna}" = ?' for kolumna in warunek)
    cursor.execute(
        f'SELECT {kolumny} FROM "{tabela}" WHERE {warunki}',
        list(warunek.values()),
    )
    rekord = cursor.fetchone()
    if rekord is not None and tuple(rekord) != tuple(dane.values()):
        raise ValueError(f"Niespójne dane istniejącego rekordu w tabeli {tabela}")


def importuj_wiersz(cursor, row):
    if wartosc(row, "ID_Zamowienia") == "ID_Zamowienia":
        return "Pominięto powtórzony nagłówek"

    if (
        liczba(row, "ID_Produktu") is None
        and wartosc(row, "Nazwa_Produktu") is None
    ):
        raise ValueError("Każdy wiersz zamówienia musi wskazywać produkt")
    if wartosc(row, "Ilosc_Zakupiona") is None:
        raise ValueError("Każdy wiersz zamówienia musi zawierać ilość produktu")
    if wartosc(row, "Cena_Historyczna") is None:
        raise ValueError(
            "Każdy wiersz zamówienia musi zawierać cenę historyczną produktu"
        )

    pola_platnosci = (
        wartosc(row, "ID_Platnosci"),
        wartosc(row, "Metoda_Platnosci"),
        wartosc(row, "Status_Platnosci"),
    )
    if any(pole is not None for pole in pola_platnosci):
        if wartosc(row, "Metoda_Platnosci") is None:
            raise ValueError("Płatność musi zawierać metodę płatności")
        if wartosc(row, "Status_Platnosci") is None:
            raise ValueError("Płatność musi zawierać status płatności")

    id_klienta = liczba(row, "ID_Klienta")
    if id_klienta is None and wartosc(row, "Email") is not None:
        id_klienta = pobierz_id(
            cursor, "Klienci", "ID_Klienta",
            {"Email": wartosc(row, "Email")}
        )
    if id_klienta is None and wartosc(row, "Imie") is not None:
        id_klienta = next_id(cursor, "Klienci", "ID_Klienta")
    if id_klienta is not None and not istnieje(
        cursor, "Klienci", {"ID_Klienta": id_klienta}
    ):
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
    elif id_klienta is not None:
        sprawdz_zgodnosc(cursor, "Klienci", "ID_Klienta", id_klienta, {
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
            cursor, "Kategorie", "ID_Kategorii",
            {"Nazwa_kategorii": wartosc(row, "Kategoria")}
        )
    if id_kategorii is None and wartosc(row, "Kategoria") is not None:
        id_kategorii = next_id(cursor, "Kategorie", "ID_Kategorii")
    if id_kategorii is not None and not istnieje(
        cursor, "Kategorie", {"ID_Kategorii": id_kategorii}
    ):
        insert(cursor, "Kategorie", {
            "ID_Kategorii": id_kategorii,
            "Nazwa_kategorii": wartosc(row, "Kategoria"),
        })

    id_producenta = liczba(row, "ID_Producenta")
    if id_producenta is None and wartosc(row, "Producent") is not None:
        id_producenta = pobierz_id(
            cursor, "Producenci", "ID_Producenta",
            {"Nazwa_producenta": wartosc(row, "Producent")}
        )
    if id_producenta is None and wartosc(row, "Producent") is not None:
        id_producenta = next_id(cursor, "Producenci", "ID_Producenta")
    if id_producenta is not None and not istnieje(
        cursor, "Producenci", {"ID_Producenta": id_producenta}
    ):
        insert(cursor, "Producenci", {
            "ID_Producenta": id_producenta,
            "Nazwa_producenta": wartosc(row, "Producent"),
            "Kraj_pochodzenia": wartosc(row, "Kraj_Producenta"),
        })

    id_kodu = liczba(row, "ID_Kodu")
    znizka = liczba(row, "Znizka", 0) or 0
    if not 0 <= znizka <= 100:
        raise ValueError("Zniżka procentowa musi być w zakresie od 0 do 100")
    if wartosc(row, "Kod_Rabatowy") is None and znizka != 0:
        raise ValueError("Nie można zastosować zniżki bez kodu rabatowego")
    if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
        id_kodu = pobierz_id(
            cursor, "Kody_Rabatowe", "ID_Kodu",
            {"Kod_tekstowy": wartosc(row, "Kod_Rabatowy")}
        )
    if id_kodu is None and wartosc(row, "Kod_Rabatowy") is not None:
        id_kodu = next_id(cursor, "Kody_Rabatowe", "ID_Kodu")
    if id_kodu is not None:
        if not istnieje(cursor, "Kody_Rabatowe", {"ID_Kodu": id_kodu}):
            insert(cursor, "Kody_Rabatowe", {
                "ID_Kodu": id_kodu,
                "Kod_tekstowy": wartosc(row, "Kod_Rabatowy"),
                "Znizka_procentowa": znizka,
            })
        else:
            sprawdz_zgodnosc(cursor, "Kody_Rabatowe", "ID_Kodu", id_kodu, {
                "Kod_tekstowy": wartosc(row, "Kod_Rabatowy"),
                "Znizka_procentowa": znizka,
            })

    id_produktu = liczba(row, "ID_Produktu")
    if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
        id_produktu = pobierz_id(
            cursor, "Produkty", "ID_Produktu",
            {
                "Nazwa": wartosc(row, "Nazwa_Produktu"),
                "ID_Producenta": id_producenta,
            }
        )
    if id_produktu is None and wartosc(row, "Nazwa_Produktu") is not None:
        id_produktu = next_id(cursor, "Produkty", "ID_Produktu")
    if id_produktu is not None:
        if id_kategorii is None or id_producenta is None:
            raise ValueError("Produkt musi mieć kategorię i producenta")
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
        else:
            sprawdz_zgodnosc(cursor, "Produkty", "ID_Produktu", id_produktu, {
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
    status_zamowienia = wartosc(row, "Status_Zamowienia")
    if status_zamowienia not in STATUSY_ZAMOWIENIA:
        raise ValueError(f"Niepoprawny status zamówienia: {status_zamowienia}")
    data_zamowienia = wartosc(row, "Data_Zamowienia")
    if data_zamowienia is None:
        raise ValueError("Brak daty zamówienia")
    cursor.execute(
        """
        SELECT ID_Klienta, ID_Kodu, Znizka_zastosowana,
               substr(Data_zamowienia, 1, 10), Status_zamowienia
        FROM Zamowienia WHERE ID_Zamowienia = ?
        """,
        (id_zamowienia,),
    )
    istniejace_zamowienie = cursor.fetchone()
    dane_zamowienia = (
        id_klienta,
        id_kodu,
        znizka,
        data_zamowienia[:10],
        status_zamowienia,
    )
    if istniejace_zamowienie and tuple(istniejace_zamowienie) != dane_zamowienia:
        raise ValueError("Niespójne dane w kolejnych wierszach tego samego zamówienia")
    if not istniejace_zamowienie:
        insert(cursor, "Zamowienia", {
            "ID_Zamowienia": id_zamowienia,
            "ID_Klienta": id_klienta,
            "ID_Kodu": id_kodu,
            "Znizka_zastosowana": znizka,
            "Data_zamowienia": data_zamowienia,
            "Status_zamowienia": status_zamowienia,
        })

    if wartosc(row, "Metoda_Platnosci") is not None:
        status_platnosci = wartosc(row, "Status_Platnosci")
        if status_platnosci not in STATUSY_PLATNOSCI:
            raise ValueError(f"Niepoprawny status płatności: {status_platnosci}")
        id_platnosci = liczba(row, "ID_Platnosci")
        if id_platnosci is None:
            id_platnosci = pobierz_id(
                cursor, "Platnosci", "ID_Platnosci",
                {"ID_Zamowienia": id_zamowienia}
            )
        if id_platnosci is None:
            id_platnosci = next_id(cursor, "Platnosci", "ID_Platnosci")
        if not istnieje(cursor, "Platnosci", {"ID_Zamowienia": id_zamowienia}):
            insert(cursor, "Platnosci", {
                "ID_Platnosci": id_platnosci,
                "ID_Zamowienia": id_zamowienia,
                "Metoda_platnosci": wartosc(row, "Metoda_Platnosci"),
                "Status_platnosci": status_platnosci,
            })
        else:
            sprawdz_zgodnosc(cursor, "Platnosci", "ID_Platnosci", id_platnosci, {
                "ID_Zamowienia": id_zamowienia,
                "Metoda_platnosci": wartosc(row, "Metoda_Platnosci"),
                "Status_platnosci": status_platnosci,
            })

    pola_wysylki = (
        wartosc(row, "ID_Wysylki"),
        wartosc(row, "Firma_Kurierska"),
        wartosc(row, "Numer_Listu"),
        wartosc(row, "Status_Paczki"),
    )
    if any(pole is not None for pole in pola_wysylki):
        status_paczki = wartosc(row, "Status_Paczki")
        if status_paczki is not None and status_paczki not in STATUSY_PACZKI:
            raise ValueError(f"Niepoprawny status paczki: {status_paczki}")
        id_wysylki = liczba(row, "ID_Wysylki")
        if id_wysylki is None:
            id_wysylki = pobierz_id(
                cursor, "Wysylki", "ID_Wysylki",
                {"ID_Zamowienia": id_zamowienia}
            )
        if id_wysylki is None:
            id_wysylki = next_id(cursor, "Wysylki", "ID_Wysylki")
        if not istnieje(cursor, "Wysylki", {"ID_Zamowienia": id_zamowienia}):
            insert(cursor, "Wysylki", {
                "ID_Wysylki": id_wysylki,
                "ID_Zamowienia": id_zamowienia,
                "Firma_kurierska": wartosc(row, "Firma_Kurierska"),
                "Numer_listu": wartosc(row, "Numer_Listu"),
                "Status_paczki": status_paczki,
            })
        else:
            sprawdz_zgodnosc(cursor, "Wysylki", "ID_Wysylki", id_wysylki, {
                "ID_Zamowienia": id_zamowienia,
                "Firma_kurierska": wartosc(row, "Firma_Kurierska"),
                "Numer_listu": wartosc(row, "Numer_Listu"),
                "Status_paczki": status_paczki,
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
        if not istnieje(cursor, "Pozycje_Zamowienia", warunek_pozycji):
            insert(cursor, "Pozycje_Zamowienia", {
                **warunek_pozycji,
                "Ilosc": ilosc,
                "Cena_historyczna": cena_historyczna,
            })
        else:
            sprawdz_zgodnosc_warunku(
                cursor,
                "Pozycje_Zamowienia",
                warunek_pozycji,
                {
                    "Ilosc": ilosc,
                    "Cena_historyczna": cena_historyczna,
                },
            )

    if wartosc(row, "Ocena_Produktu") is not None:
        if status_zamowienia != "Dostarczone":
            raise ValueError("Opinię można dodać tylko do dostarczonego zamówienia")
        warunek_opinii = {
            "ID_Zamowienia": id_zamowienia,
            "ID_Produktu": id_produktu,
        }
        if not istnieje(cursor, "Pozycje_Zamowienia", warunek_opinii):
            raise ValueError(
                "Nie można dodać opinii, bo nie istnieje taka pozycja zamówienia"
            )
        ocena = liczba(row, "Ocena_Produktu")
        if ocena is None or not 1 <= ocena <= 5:
            raise ValueError("Ocena musi być w zakresie od 1 do 5")
        id_opinii = liczba(row, "ID_Opinii")
        if id_opinii is None:
            id_opinii = pobierz_id(cursor, "Opinie", "ID_Opinii", warunek_opinii)
        if id_opinii is None:
            id_opinii = next_id(cursor, "Opinie", "ID_Opinii")
        if not istnieje(cursor, "Opinie", warunek_opinii):
            insert(cursor, "Opinie", {
                "ID_Opinii": id_opinii,
                **warunek_opinii,
                "Ocena": ocena,
                "Komentarz": wartosc(row, "Komentarz"),
            })

    return "OK"


def importuj_csv_sqlite(
    sciezka_bazy=SCIEZKA_BAZY,
    sciezka_csv=SCIEZKA_CSV,
    separator=SEPARATOR,
):
    conn = sqlite3.connect(sciezka_bazy)
    conn.execute("PRAGMA foreign_keys = ON")
    cursor = conn.cursor()
    licznik_ok = 0
    licznik_bledow = 0
    bledy = []

    with open(sciezka_csv, newline="", encoding="utf-8") as plik:
        reader = csv.DictReader(plik, delimiter=separator)
        zamowienia = OrderedDict()
        for nr, row in enumerate(reader, start=2):
            id_zamowienia = wartosc(row, "ID_Zamowienia")
            if id_zamowienia == "ID_Zamowienia":
                continue
            zamowienia.setdefault(id_zamowienia, []).append((nr, row))

        for id_zamowienia, wiersze in zamowienia.items():
            try:
                for _, row in wiersze:
                    importuj_wiersz(cursor, row)
                conn.commit()
                licznik_ok += len(wiersze)
            except Exception as blad:
                conn.rollback()
                licznik_bledow += len(wiersze)
                numery = ", ".join(str(nr) for nr, _ in wiersze)
                komunikat = (
                    f"Błąd zamówienia {id_zamowienia} "
                    f"(wiersze {numery}): {blad}"
                )
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


if __name__ == "__main__":
    importuj_csv_sqlite(SCIEZKA_BAZY, SCIEZKA_CSV, SEPARATOR)
