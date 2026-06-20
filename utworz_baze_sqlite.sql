-- =========================================
-- TWORZENIE TABEL - SKLEP INTERNETOWY
-- SQLite
-- =========================================

PRAGMA foreign_keys = ON;

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

CREATE TABLE Kategorie (
    ID_Kategorii INTEGER PRIMARY KEY AUTOINCREMENT,
    Nazwa_kategorii TEXT UNIQUE NOT NULL
);

CREATE TABLE Producenci (
    ID_Producenta INTEGER PRIMARY KEY AUTOINCREMENT,
    Nazwa_producenta TEXT UNIQUE NOT NULL,
    Kraj_pochodzenia TEXT
);

CREATE TABLE Kody_Rabatowe (
    ID_Kodu INTEGER PRIMARY KEY AUTOINCREMENT,
    Kod_tekstowy TEXT UNIQUE NOT NULL,
    Znizka_procentowa INTEGER NOT NULL
        CHECK (Znizka_procentowa BETWEEN 0 AND 100)
);

CREATE TABLE Produkty (
    ID_Produktu INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Kategorii INTEGER NOT NULL,
    ID_Producenta INTEGER NOT NULL,
    Nazwa TEXT NOT NULL,
    Opis TEXT,
    Cena_aktualna REAL NOT NULL
        CHECK (Cena_aktualna >= 0),
    Stan_magazynowy INTEGER NOT NULL DEFAULT 0
        CHECK (Stan_magazynowy >= 0),

    UNIQUE (Nazwa, ID_Producenta),

    FOREIGN KEY (ID_Kategorii)
        REFERENCES Kategorie(ID_Kategorii)
        ON DELETE RESTRICT,

    FOREIGN KEY (ID_Producenta)
        REFERENCES Producenci(ID_Producenta)
        ON DELETE RESTRICT
);

CREATE TABLE Zamowienia (
    ID_Zamowienia INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Klienta INTEGER NOT NULL,
    ID_Kodu INTEGER,
    Znizka_zastosowana INTEGER NOT NULL DEFAULT 0
        CHECK (Znizka_zastosowana BETWEEN 0 AND 100),
    Data_zamowienia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status_zamowienia TEXT NOT NULL
        CHECK (Status_zamowienia IN
            ('Nowe', 'Opłacone', 'Wysłane', 'Dostarczone', 'Anulowane')),

    FOREIGN KEY (ID_Klienta)
        REFERENCES Klienci(ID_Klienta)
        ON DELETE RESTRICT,

    FOREIGN KEY (ID_Kodu)
        REFERENCES Kody_Rabatowe(ID_Kodu)
        ON DELETE SET NULL
);

CREATE TABLE Platnosci (
    ID_Platnosci INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Zamowienia INTEGER UNIQUE NOT NULL,
    Metoda_platnosci TEXT NOT NULL,
    Status_platnosci TEXT NOT NULL
        CHECK (Status_platnosci IN
            ('Oczekująca', 'Zakończona', 'Odrzucona')),

    FOREIGN KEY (ID_Zamowienia)
        REFERENCES Zamowienia(ID_Zamowienia)
        ON DELETE CASCADE
);

CREATE TABLE Pozycje_Zamowienia (
    ID_Zamowienia INTEGER NOT NULL,
    ID_Produktu INTEGER NOT NULL,
    Ilosc INTEGER NOT NULL CHECK (Ilosc > 0),
    Cena_historyczna REAL NOT NULL
        CHECK (Cena_historyczna >= 0),

    PRIMARY KEY (ID_Zamowienia, ID_Produktu),

    FOREIGN KEY (ID_Zamowienia)
        REFERENCES Zamowienia(ID_Zamowienia)
        ON DELETE CASCADE,

    FOREIGN KEY (ID_Produktu)
        REFERENCES Produkty(ID_Produktu)
        ON DELETE RESTRICT
);

CREATE TABLE Wysylki (
    ID_Wysylki INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Zamowienia INTEGER UNIQUE NOT NULL,
    Firma_kurierska TEXT,
    Numer_listu TEXT UNIQUE,
    Status_paczki TEXT
        CHECK (Status_paczki IS NULL OR Status_paczki IN
            ('Przygotowywana', 'Nadana', 'W transporcie', 'Doręczona', 'Zwrócona')),

    FOREIGN KEY (ID_Zamowienia)
        REFERENCES Zamowienia(ID_Zamowienia)
        ON DELETE CASCADE
);

CREATE TABLE Opinie (
    ID_Opinii INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Zamowienia INTEGER NOT NULL,
    ID_Produktu INTEGER NOT NULL,
    Ocena INTEGER NOT NULL CHECK (Ocena BETWEEN 1 AND 5),
    Komentarz TEXT,

    FOREIGN KEY (ID_Zamowienia, ID_Produktu)
        REFERENCES Pozycje_Zamowienia(ID_Zamowienia, ID_Produktu)
        ON DELETE CASCADE,

    UNIQUE (ID_Zamowienia, ID_Produktu)
);

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
