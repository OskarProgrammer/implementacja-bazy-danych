--
-- PostgreSQL database dump
--

\restrict tL15aTvr1K5F5PJf0Cgwd1tdEQK3VBFrZuQqNM1dIddKMGTSkGgkxXfNGGynH75

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg13+1)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg13+1)

-- Started on 2026-06-20 10:33:11 CEST

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
-- TOC entry 222 (class 1259 OID 41793)
-- Name: kategorie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kategorie (
    id_kategorii integer NOT NULL,
    nazwa_kategorii character varying(50) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 41792)
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
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 221
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNED BY public.kategorie.id_kategorii;


--
-- TOC entry 220 (class 1259 OID 41778)
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
-- TOC entry 219 (class 1259 OID 41777)
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
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 219
-- Name: klienci_id_klienta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.klienci_id_klienta_seq OWNED BY public.klienci.id_klienta;


--
-- TOC entry 226 (class 1259 OID 41815)
-- Name: kody_rabatowe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kody_rabatowe (
    id_kodu integer NOT NULL,
    kod_tekstowy character varying(20) NOT NULL,
    znizka_procentowa smallint NOT NULL,
    CONSTRAINT kody_rabatowe_znizka_procentowa_check CHECK (((znizka_procentowa >= 0) AND (znizka_procentowa <= 100)))
);


--
-- TOC entry 225 (class 1259 OID 41814)
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
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 225
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kody_rabatowe_id_kodu_seq OWNED BY public.kody_rabatowe.id_kodu;


--
-- TOC entry 237 (class 1259 OID 41943)
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
-- TOC entry 236 (class 1259 OID 41942)
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
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 236
-- Name: opinie_id_opinii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.opinie_id_opinii_seq OWNED BY public.opinie.id_opinii;


--
-- TOC entry 232 (class 1259 OID 41884)
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
-- TOC entry 231 (class 1259 OID 41883)
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
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 231
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.platnosci_id_platnosci_seq OWNED BY public.platnosci.id_platnosci;


--
-- TOC entry 233 (class 1259 OID 41902)
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
-- TOC entry 224 (class 1259 OID 41804)
-- Name: producenci; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.producenci (
    id_producenta integer NOT NULL,
    nazwa_producenta character varying(100) NOT NULL,
    kraj_pochodzenia character varying(50)
);


--
-- TOC entry 223 (class 1259 OID 41803)
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
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 223
-- Name: producenci_id_producenta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.producenci_id_producenta_seq OWNED BY public.producenci.id_producenta;


--
-- TOC entry 228 (class 1259 OID 41828)
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
-- TOC entry 227 (class 1259 OID 41827)
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
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkty_id_produktu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.produkty_id_produktu_seq OWNED BY public.produkty.id_produktu;


--
-- TOC entry 235 (class 1259 OID 41924)
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
-- TOC entry 234 (class 1259 OID 41923)
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
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 234
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wysylki_id_wysylki_seq OWNED BY public.wysylki.id_wysylki;


--
-- TOC entry 230 (class 1259 OID 41858)
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
-- TOC entry 229 (class 1259 OID 41857)
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
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 229
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zamowienia_id_zamowienia_seq OWNED BY public.zamowienia.id_zamowienia;


--
-- TOC entry 3334 (class 2604 OID 41796)
-- Name: kategorie id_kategorii; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kategorie ALTER COLUMN id_kategorii SET DEFAULT nextval('public.kategorie_id_kategorii_seq'::regclass);


--
-- TOC entry 3333 (class 2604 OID 41781)
-- Name: klienci id_klienta; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klienci ALTER COLUMN id_klienta SET DEFAULT nextval('public.klienci_id_klienta_seq'::regclass);


--
-- TOC entry 3336 (class 2604 OID 41818)
-- Name: kody_rabatowe id_kodu; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kody_rabatowe ALTER COLUMN id_kodu SET DEFAULT nextval('public.kody_rabatowe_id_kodu_seq'::regclass);


--
-- TOC entry 3344 (class 2604 OID 41946)
-- Name: opinie id_opinii; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opinie ALTER COLUMN id_opinii SET DEFAULT nextval('public.opinie_id_opinii_seq'::regclass);


--
-- TOC entry 3342 (class 2604 OID 41887)
-- Name: platnosci id_platnosci; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platnosci ALTER COLUMN id_platnosci SET DEFAULT nextval('public.platnosci_id_platnosci_seq'::regclass);


--
-- TOC entry 3335 (class 2604 OID 41807)
-- Name: producenci id_producenta; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producenci ALTER COLUMN id_producenta SET DEFAULT nextval('public.producenci_id_producenta_seq'::regclass);


--
-- TOC entry 3337 (class 2604 OID 41831)
-- Name: produkty id_produktu; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produkty ALTER COLUMN id_produktu SET DEFAULT nextval('public.produkty_id_produktu_seq'::regclass);


--
-- TOC entry 3343 (class 2604 OID 41927)
-- Name: wysylki id_wysylki; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wysylki ALTER COLUMN id_wysylki SET DEFAULT nextval('public.wysylki_id_wysylki_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 41861)
-- Name: zamowienia id_zamowienia; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zamowienia ALTER COLUMN id_zamowienia SET DEFAULT nextval('public.zamowienia_id_zamowienia_seq'::regclass);


--
-- TOC entry 3556 (class 0 OID 41793)
-- Dependencies: 222
-- Data for Name: kategorie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kategorie (id_kategorii, nazwa_kategorii) FROM stdin;
1	Elektronika
\.


--
-- TOC entry 3554 (class 0 OID 41778)
-- Dependencies: 220
-- Data for Name: klienci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.klienci (id_klienta, imie, nazwisko, email, telefon, miasto, ulica, kod_pocztowy) FROM stdin;
1	Piotr	Nowak	p.nowak@pwr.edu.pl	600700800	Wrocław	Wybrzeże Wyspiańskiego 27	50-370
\.


--
-- TOC entry 3560 (class 0 OID 41815)
-- Dependencies: 226
-- Data for Name: kody_rabatowe; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.kody_rabatowe (id_kodu, kod_tekstowy, znizka_procentowa) FROM stdin;
1	STUDENT20	20
\.


--
-- TOC entry 3571 (class 0 OID 41943)
-- Dependencies: 237
-- Data for Name: opinie; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.opinie (id_opinii, id_zamowienia, id_produktu, ocena, komentarz) FROM stdin;
1	1	1	5	Świetny monitor, polecam!
2	1	2	4	Dobry kabel, ale sztywny.
\.


--
-- TOC entry 3566 (class 0 OID 41884)
-- Dependencies: 232
-- Data for Name: platnosci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.platnosci (id_platnosci, id_zamowienia, metoda_platnosci, status_platnosci) FROM stdin;
1	1	BLIK	Zakończona
\.


--
-- TOC entry 3567 (class 0 OID 41902)
-- Dependencies: 233
-- Data for Name: pozycje_zamowienia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pozycje_zamowienia (id_zamowienia, id_produktu, ilosc, cena_historyczna) FROM stdin;
1	1	1	1200.00
1	2	2	45.00
\.


--
-- TOC entry 3558 (class 0 OID 41804)
-- Dependencies: 224
-- Data for Name: producenci; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.producenci (id_producenta, nazwa_producenta, kraj_pochodzenia) FROM stdin;
1	Samsung	Korea Pd.
2	Logitech	Szwajcaria
\.


--
-- TOC entry 3562 (class 0 OID 41828)
-- Dependencies: 228
-- Data for Name: produkty; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.produkty (id_produktu, id_kategorii, id_producenta, nazwa, opis, cena_aktualna, stan_magazynowy) FROM stdin;
1	1	1	Monitor 4K	\N	1200.00	10
2	1	2	Kabel HDMI	\N	50.00	50
\.


--
-- TOC entry 3569 (class 0 OID 41924)
-- Dependencies: 235
-- Data for Name: wysylki; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wysylki (id_wysylki, id_zamowienia, firma_kurierska, numer_listu, status_paczki) FROM stdin;
1	1	InPost	654321987	Doręczona
\.


--
-- TOC entry 3564 (class 0 OID 41858)
-- Dependencies: 230
-- Data for Name: zamowienia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zamowienia (id_zamowienia, id_klienta, id_kodu, znizka_zastosowana, data_zamowienia, status_zamowienia) FROM stdin;
1	1	1	20	2023-11-20 00:00:00	Dostarczone
\.


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 221
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kategorie_id_kategorii_seq', 1, true);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 219
-- Name: klienci_id_klienta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.klienci_id_klienta_seq', 1, true);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 225
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kody_rabatowe_id_kodu_seq', 1, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 236
-- Name: opinie_id_opinii_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.opinie_id_opinii_seq', 2, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 231
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.platnosci_id_platnosci_seq', 1, true);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 223
-- Name: producenci_id_producenta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.producenci_id_producenta_seq', 2, true);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 227
-- Name: produkty_id_produktu_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produkty_id_produktu_seq', 2, true);


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 234
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wysylki_id_wysylki_seq', 1, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 229
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.zamowienia_id_zamowienia_seq', 1, true);


-- Completed on 2026-06-20 10:33:11 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict tL15aTvr1K5F5PJf0Cgwd1tdEQK3VBFrZuQqNM1dIddKMGTSkGgkxXfNGGynH75
