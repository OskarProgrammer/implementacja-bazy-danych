--
-- PostgreSQL database dump
--

\restrict 6aBQwABrCT133TxImnK2H8cagQUhLFGatftSUIrsriNSQxGDsFazjq6eihrYiNO

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg13+1)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg13+1)

-- Started on 2026-06-20 09:53:21 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 41600)
-- Name: kategorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kategorie (
    id_kategorii integer NOT NULL,
    nazwa_kategorii character varying(50) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 41599)
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kategorie_id_kategorii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 221
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNED BY public.kategorie.id_kategorii;


--
-- TOC entry 220 (class 1259 OID 41585)
-- Name: klienci; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.klienci (
    id_klienta integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    telefon character varying(15),
    miasto character varying(100),
    ulica character varying(150),
    kod_pocztowy character varying(10)
);


--
-- TOC entry 219 (class 1259 OID 41584)
-- Name: klienci_id_klienta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.klienci_id_klienta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 219
-- Name: klienci_id_klienta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.klienci_id_klienta_seq OWNED BY public.klienci.id_klienta;


--
-- TOC entry 226 (class 1259 OID 41622)
-- Name: kody_rabatowe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kody_rabatowe (
    id_kodu integer NOT NULL,
    kod_tekstowy character varying(20) NOT NULL,
    znizka_procentowa smallint NOT NULL,
    CONSTRAINT kody_rabatowe_znizka_procentowa_check CHECK (((znizka_procentowa >= 0) AND (znizka_procentowa <= 100)))
);


--
-- TOC entry 225 (class 1259 OID 41621)
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kody_rabatowe_id_kodu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 225
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kody_rabatowe_id_kodu_seq OWNED BY public.kody_rabatowe.id_kodu;


--
-- TOC entry 237 (class 1259 OID 41750)
-- Name: opinie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opinie (
    id_opinii integer NOT NULL,
    id_zamowienia integer NOT NULL,
    id_produktu integer NOT NULL,
    ocena smallint NOT NULL,
    komentarz text,
    CONSTRAINT opinie_ocena_check CHECK (((ocena >= 1) AND (ocena <= 5)))
);


--
-- TOC entry 236 (class 1259 OID 41749)
-- Name: opinie_id_opinii_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.opinie_id_opinii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 236
-- Name: opinie_id_opinii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opinie_id_opinii_seq OWNED BY public.opinie.id_opinii;


--
-- TOC entry 232 (class 1259 OID 41691)
-- Name: platnosci; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.platnosci (
    id_platnosci integer NOT NULL,
    id_zamowienia integer NOT NULL,
    metoda_platnosci character varying(50) NOT NULL,
    status_platnosci character varying(30) NOT NULL,
    CONSTRAINT platnosci_status_platnosci_check CHECK (((status_platnosci)::text = ANY ((ARRAY['Oczekująca'::character varying, 'Zakończona'::character varying, 'Odrzucona'::character varying])::text[])))
);


--
-- TOC entry 231 (class 1259 OID 41690)
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.platnosci_id_platnosci_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 231
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.platnosci_id_platnosci_seq OWNED BY public.platnosci.id_platnosci;


--
-- TOC entry 233 (class 1259 OID 41709)
-- Name: pozycje_zamowienia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pozycje_zamowienia (
    id_zamowienia integer NOT NULL,
    id_produktu integer NOT NULL,
    ilosc integer NOT NULL,
    cena_historyczna numeric(10,2) NOT NULL,
    CONSTRAINT pozycje_zamowienia_cena_historyczna_check CHECK ((cena_historyczna >= (0)::numeric)),
    CONSTRAINT pozycje_zamowienia_ilosc_check CHECK ((ilosc > 0))
);


--
-- TOC entry 224 (class 1259 OID 41611)
-- Name: producenci; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.producenci (
    id_producenta integer NOT NULL,
    nazwa_producenta character varying(100) NOT NULL,
    kraj_pochodzenia character varying(50)
);


--
-- TOC entry 223 (class 1259 OID 41610)
-- Name: producenci_id_producenta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.producenci_id_producenta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 223
-- Name: producenci_id_producenta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.producenci_id_producenta_seq OWNED BY public.producenci.id_producenta;


--
-- TOC entry 228 (class 1259 OID 41635)
-- Name: produkty; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produkty (
    id_produktu integer NOT NULL,
    id_kategorii integer NOT NULL,
    id_producenta integer NOT NULL,
    nazwa character varying(150) NOT NULL,
    opis text,
    cena_aktualna numeric(10,2) NOT NULL,
    stan_magazynowy integer DEFAULT 0 NOT NULL,
    CONSTRAINT produkty_cena_aktualna_check CHECK ((cena_aktualna >= (0)::numeric)),
    CONSTRAINT produkty_stan_magazynowy_check CHECK ((stan_magazynowy >= 0))
);


--
-- TOC entry 227 (class 1259 OID 41634)
-- Name: produkty_id_produktu_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.produkty_id_produktu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkty_id_produktu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.produkty_id_produktu_seq OWNED BY public.produkty.id_produktu;


--
-- TOC entry 235 (class 1259 OID 41731)
-- Name: wysylki; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wysylki (
    id_wysylki integer NOT NULL,
    id_zamowienia integer NOT NULL,
    firma_kurierska character varying(100),
    numer_listu character varying(100),
    status_paczki character varying(50),
    CONSTRAINT wysylki_status_paczki_check CHECK (((status_paczki IS NULL) OR ((status_paczki)::text = ANY ((ARRAY['Przygotowywana'::character varying, 'Nadana'::character varying, 'W transporcie'::character varying, 'Doręczona'::character varying, 'Zwrócona'::character varying])::text[]))))
);


--
-- TOC entry 234 (class 1259 OID 41730)
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wysylki_id_wysylki_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 234
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wysylki_id_wysylki_seq OWNED BY public.wysylki.id_wysylki;


--
-- TOC entry 230 (class 1259 OID 41665)
-- Name: zamowienia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zamowienia (
    id_zamowienia integer NOT NULL,
    id_klienta integer NOT NULL,
    id_kodu integer,
    znizka_zastosowana smallint DEFAULT 0 NOT NULL,
    data_zamowienia timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status_zamowienia character varying(30) NOT NULL,
    CONSTRAINT zamowienia_status_zamowienia_check CHECK (((status_zamowienia)::text = ANY ((ARRAY['Nowe'::character varying, 'Opłacone'::character varying, 'Wysłane'::character varying, 'Dostarczone'::character varying, 'Anulowane'::character varying])::text[]))),
    CONSTRAINT zamowienia_znizka_zastosowana_check CHECK (((znizka_zastosowana >= 0) AND (znizka_zastosowana <= 100)))
);


--
-- TOC entry 229 (class 1259 OID 41664)
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.zamowienia_id_zamowienia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 229
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zamowienia_id_zamowienia_seq OWNED BY public.zamowienia.id_zamowienia;


--
-- TOC entry 3334 (class 2604 OID 41603)
-- Name: kategorie id_kategorii; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kategorie ALTER COLUMN id_kategorii SET DEFAULT nextval('public.kategorie_id_kategorii_seq'::regclass);


--
-- TOC entry 3333 (class 2604 OID 41588)
-- Name: klienci id_klienta; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klienci ALTER COLUMN id_klienta SET DEFAULT nextval('public.klienci_id_klienta_seq'::regclass);


--
-- TOC entry 3336 (class 2604 OID 41625)
-- Name: kody_rabatowe id_kodu; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kody_rabatowe ALTER COLUMN id_kodu SET DEFAULT nextval('public.kody_rabatowe_id_kodu_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 41753)
-- Name: opinie id_opinii; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opinie ALTER COLUMN id_opinii SET DEFAULT nextval('public.opinie_id_opinii_seq'::regclass);


--
-- TOC entry 3342 (class 2604 OID 41694)
-- Name: platnosci id_platnosci; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platnosci ALTER COLUMN id_platnosci SET DEFAULT nextval('public.platnosci_id_platnosci_seq'::regclass);


--
-- TOC entry 3335 (class 2604 OID 41614)
-- Name: producenci id_producenta; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producenci ALTER COLUMN id_producenta SET DEFAULT nextval('public.producenci_id_producenta_seq'::regclass);


--
-- TOC entry 3337 (class 2604 OID 41638)
-- Name: produkty id_produktu; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty ALTER COLUMN id_produktu SET DEFAULT nextval('public.produkty_id_produktu_seq'::regclass);


--
-- TOC entry 3343 (class 2604 OID 41734)
-- Name: wysylki id_wysylki; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki ALTER COLUMN id_wysylki SET DEFAULT nextval('public.wysylki_id_wysylki_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 41668)
-- Name: zamowienia id_zamowienia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zamowienia ALTER COLUMN id_zamowienia SET DEFAULT nextval('public.zamowienia_id_zamowienia_seq'::regclass);


--
-- TOC entry 3558 (class 0 OID 41600)
-- Dependencies: 222
-- Data for Name: kategorie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kategorie (id_kategorii, nazwa_kategorii) FROM stdin;
1	Elektronika
\.


--
-- TOC entry 3556 (class 0 OID 41585)
-- Dependencies: 220
-- Data for Name: klienci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.klienci (id_klienta, imie, nazwisko, email, telefon, miasto, ulica, kod_pocztowy) FROM stdin;
1	Piotr	Nowak	p.nowak@pwr.edu.pl	600700800	Wrocław	Wybrzeże Wyspiańskiego 27	50-370
\.


--
-- TOC entry 3562 (class 0 OID 41622)
-- Dependencies: 226
-- Data for Name: kody_rabatowe; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kody_rabatowe (id_kodu, kod_tekstowy, znizka_procentowa) FROM stdin;
1	STUDENT20	20
\.


--
-- TOC entry 3573 (class 0 OID 41750)
-- Dependencies: 237
-- Data for Name: opinie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.opinie (id_opinii, id_zamowienia, id_produktu, ocena, komentarz) FROM stdin;
1	1	1	5	Świetny monitor, polecam!
2	1	2	4	Dobry kabel, ale sztywny.
\.


--
-- TOC entry 3568 (class 0 OID 41691)
-- Dependencies: 232
-- Data for Name: platnosci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.platnosci (id_platnosci, id_zamowienia, metoda_platnosci, status_platnosci) FROM stdin;
1	1	BLIK	Zakończona
\.


--
-- TOC entry 3569 (class 0 OID 41709)
-- Dependencies: 233
-- Data for Name: pozycje_zamowienia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pozycje_zamowienia (id_zamowienia, id_produktu, ilosc, cena_historyczna) FROM stdin;
1	1	1	1200.00
1	2	2	45.00
\.


--
-- TOC entry 3560 (class 0 OID 41611)
-- Dependencies: 224
-- Data for Name: producenci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.producenci (id_producenta, nazwa_producenta, kraj_pochodzenia) FROM stdin;
1	Samsung	Korea Pd.
2	Logitech	Szwajcaria
\.


--
-- TOC entry 3564 (class 0 OID 41635)
-- Dependencies: 228
-- Data for Name: produkty; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.produkty (id_produktu, id_kategorii, id_producenta, nazwa, opis, cena_aktualna, stan_magazynowy) FROM stdin;
1	1	1	Monitor 4K	\N	1200.00	10
2	1	2	Kabel HDMI	\N	50.00	50
\.


--
-- TOC entry 3571 (class 0 OID 41731)
-- Dependencies: 235
-- Data for Name: wysylki; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wysylki (id_wysylki, id_zamowienia, firma_kurierska, numer_listu, status_paczki) FROM stdin;
1	1	InPost	654321987	Doręczona
\.


--
-- TOC entry 3566 (class 0 OID 41665)
-- Dependencies: 230
-- Data for Name: zamowienia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zamowienia (id_zamowienia, id_klienta, id_kodu, znizka_zastosowana, data_zamowienia, status_zamowienia) FROM stdin;
1	1	1	20	2023-11-20 00:00:00	Dostarczone
\.


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 221
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kategorie_id_kategorii_seq', 1, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 219
-- Name: klienci_id_klienta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.klienci_id_klienta_seq', 1, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 225
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kody_rabatowe_id_kodu_seq', 1, true);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 236
-- Name: opinie_id_opinii_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.opinie_id_opinii_seq', 2, true);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 231
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.platnosci_id_platnosci_seq', 1, true);


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 223
-- Name: producenci_id_producenta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.producenci_id_producenta_seq', 2, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkty_id_produktu_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produkty_id_produktu_seq', 2, true);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 234
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wysylki_id_wysylki_seq', 1, true);


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 229
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.zamowienia_id_zamowienia_seq', 1, true);


--
-- TOC entry 3360 (class 2606 OID 41609)
-- Name: kategorie kategorie_nazwa_kategorii_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_nazwa_kategorii_key UNIQUE (nazwa_kategorii);


--
-- TOC entry 3362 (class 2606 OID 41607)
-- Name: kategorie kategorie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_pkey PRIMARY KEY (id_kategorii);


--
-- TOC entry 3356 (class 2606 OID 41598)
-- Name: klienci klienci_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klienci
    ADD CONSTRAINT klienci_email_key UNIQUE (email);


--
-- TOC entry 3358 (class 2606 OID 41596)
-- Name: klienci klienci_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klienci
    ADD CONSTRAINT klienci_pkey PRIMARY KEY (id_klienta);


--
-- TOC entry 3368 (class 2606 OID 41633)
-- Name: kody_rabatowe kody_rabatowe_kod_tekstowy_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kody_rabatowe
    ADD CONSTRAINT kody_rabatowe_kod_tekstowy_key UNIQUE (kod_tekstowy);


--
-- TOC entry 3370 (class 2606 OID 41631)
-- Name: kody_rabatowe kody_rabatowe_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kody_rabatowe
    ADD CONSTRAINT kody_rabatowe_pkey PRIMARY KEY (id_kodu);


--
-- TOC entry 3396 (class 2606 OID 41762)
-- Name: opinie opinie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT opinie_pkey PRIMARY KEY (id_opinii);


--
-- TOC entry 3382 (class 2606 OID 41703)
-- Name: platnosci platnosci_id_zamowienia_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT platnosci_id_zamowienia_key UNIQUE (id_zamowienia);


--
-- TOC entry 3384 (class 2606 OID 41701)
-- Name: platnosci platnosci_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT platnosci_pkey PRIMARY KEY (id_platnosci);


--
-- TOC entry 3387 (class 2606 OID 41719)
-- Name: pozycje_zamowienia pozycje_zamowienia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT pozycje_zamowienia_pkey PRIMARY KEY (id_zamowienia, id_produktu);


--
-- TOC entry 3364 (class 2606 OID 41620)
-- Name: producenci producenci_nazwa_producenta_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producenci
    ADD CONSTRAINT producenci_nazwa_producenta_key UNIQUE (nazwa_producenta);


--
-- TOC entry 3366 (class 2606 OID 41618)
-- Name: producenci producenci_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producenci
    ADD CONSTRAINT producenci_pkey PRIMARY KEY (id_producenta);


--
-- TOC entry 3374 (class 2606 OID 41651)
-- Name: produkty produkty_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT produkty_pkey PRIMARY KEY (id_produktu);


--
-- TOC entry 3398 (class 2606 OID 41764)
-- Name: opinie uq_opinie_pozycja; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT uq_opinie_pozycja UNIQUE (id_zamowienia, id_produktu);


--
-- TOC entry 3376 (class 2606 OID 41653)
-- Name: produkty uq_produkty_nazwa_producent; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT uq_produkty_nazwa_producent UNIQUE (nazwa, id_producenta);


--
-- TOC entry 3390 (class 2606 OID 41741)
-- Name: wysylki wysylki_id_zamowienia_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_id_zamowienia_key UNIQUE (id_zamowienia);


--
-- TOC entry 3392 (class 2606 OID 41743)
-- Name: wysylki wysylki_numer_listu_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_numer_listu_key UNIQUE (numer_listu);


--
-- TOC entry 3394 (class 2606 OID 41739)
-- Name: wysylki wysylki_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_pkey PRIMARY KEY (id_wysylki);


--
-- TOC entry 3379 (class 2606 OID 41679)
-- Name: zamowienia zamowienia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT zamowienia_pkey PRIMARY KEY (id_zamowienia);


--
-- TOC entry 3380 (class 1259 OID 41774)
-- Name: idx_platnosci_zamowienie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_platnosci_zamowienie ON public.platnosci USING btree (id_zamowienia);


--
-- TOC entry 3385 (class 1259 OID 41773)
-- Name: idx_pozycje_produkt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pozycje_produkt ON public.pozycje_zamowienia USING btree (id_produktu);


--
-- TOC entry 3371 (class 1259 OID 41770)
-- Name: idx_produkty_kategoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_produkty_kategoria ON public.produkty USING btree (id_kategorii);


--
-- TOC entry 3372 (class 1259 OID 41771)
-- Name: idx_produkty_producent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_produkty_producent ON public.produkty USING btree (id_producenta);


--
-- TOC entry 3388 (class 1259 OID 41775)
-- Name: idx_wysylki_zamowienie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wysylki_zamowienie ON public.wysylki USING btree (id_zamowienia);


--
-- TOC entry 3377 (class 1259 OID 41772)
-- Name: idx_zamowienia_klient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_zamowienia_klient ON public.zamowienia USING btree (id_klienta);


--
-- TOC entry 3407 (class 2606 OID 41765)
-- Name: opinie fk_opinie_pozycje; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT fk_opinie_pozycje FOREIGN KEY (id_zamowienia, id_produktu) REFERENCES public.pozycje_zamowienia(id_zamowienia, id_produktu) ON DELETE CASCADE;


--
-- TOC entry 3403 (class 2606 OID 41704)
-- Name: platnosci fk_platnosci_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT fk_platnosci_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- TOC entry 3404 (class 2606 OID 41725)
-- Name: pozycje_zamowienia fk_pozycje_produkty; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT fk_pozycje_produkty FOREIGN KEY (id_produktu) REFERENCES public.produkty(id_produktu) ON DELETE RESTRICT;


--
-- TOC entry 3405 (class 2606 OID 41720)
-- Name: pozycje_zamowienia fk_pozycje_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT fk_pozycje_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- TOC entry 3399 (class 2606 OID 41654)
-- Name: produkty fk_produkty_kategorie; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT fk_produkty_kategorie FOREIGN KEY (id_kategorii) REFERENCES public.kategorie(id_kategorii) ON DELETE RESTRICT;


--
-- TOC entry 3400 (class 2606 OID 41659)
-- Name: produkty fk_produkty_producenci; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT fk_produkty_producenci FOREIGN KEY (id_producenta) REFERENCES public.producenci(id_producenta) ON DELETE RESTRICT;


--
-- TOC entry 3406 (class 2606 OID 41744)
-- Name: wysylki fk_wysylki_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT fk_wysylki_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- TOC entry 3401 (class 2606 OID 41680)
-- Name: zamowienia fk_zamowienia_klienci; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT fk_zamowienia_klienci FOREIGN KEY (id_klienta) REFERENCES public.klienci(id_klienta) ON DELETE RESTRICT;


--
-- TOC entry 3402 (class 2606 OID 41685)
-- Name: zamowienia fk_zamowienia_kody; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT fk_zamowienia_kody FOREIGN KEY (id_kodu) REFERENCES public.kody_rabatowe(id_kodu) ON DELETE SET NULL;


-- Completed on 2026-06-20 09:53:21 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict 6aBQwABrCT133TxImnK2H8cagQUhLFGatftSUIrsriNSQxGDsFazjq6eihrYiNO

