--
-- PostgreSQL database dump
--

\restrict 1kpd3JsDpDHbvbqDAxFBeGDWkcQFmcjGCWZlLzeTTqFCeeVcT7P86DRi7zs6zTr

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3 (Debian 18.3-1.pgdg13+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: kategorie; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.kategorie (
    id_kategorii integer NOT NULL,
    nazwa_kategorii character varying(50) NOT NULL
);


ALTER TABLE public.kategorie OWNER TO student23;

--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.kategorie_id_kategorii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNER TO student23;

--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.kategorie_id_kategorii_seq OWNED BY public.kategorie.id_kategorii;


--
-- Name: klienci; Type: TABLE; Schema: public; Owner: student23
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


ALTER TABLE public.klienci OWNER TO student23;

--
-- Name: klienci_id_klienta_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.klienci_id_klienta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.klienci_id_klienta_seq OWNER TO student23;

--
-- Name: klienci_id_klienta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.klienci_id_klienta_seq OWNED BY public.klienci.id_klienta;


--
-- Name: kody_rabatowe; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.kody_rabatowe (
    id_kodu integer NOT NULL,
    kod_tekstowy character varying(20) NOT NULL,
    znizka_procentowa smallint,
    CONSTRAINT kody_rabatowe_znizka_procentowa_check CHECK (((znizka_procentowa >= 0) AND (znizka_procentowa <= 100)))
);


ALTER TABLE public.kody_rabatowe OWNER TO student23;

--
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.kody_rabatowe_id_kodu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kody_rabatowe_id_kodu_seq OWNER TO student23;

--
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.kody_rabatowe_id_kodu_seq OWNED BY public.kody_rabatowe.id_kodu;


--
-- Name: opinie; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.opinie (
    id_opinii integer NOT NULL,
    id_zamowienia integer NOT NULL,
    id_produktu integer NOT NULL,
    ocena smallint NOT NULL,
    komentarz text,
    CONSTRAINT opinie_ocena_check CHECK (((ocena >= 1) AND (ocena <= 5)))
);


ALTER TABLE public.opinie OWNER TO student23;

--
-- Name: opinie_id_opinii_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.opinie_id_opinii_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opinie_id_opinii_seq OWNER TO student23;

--
-- Name: opinie_id_opinii_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.opinie_id_opinii_seq OWNED BY public.opinie.id_opinii;


--
-- Name: platnosci; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.platnosci (
    id_platnosci integer NOT NULL,
    id_zamowienia integer NOT NULL,
    metoda_platnosci character varying(50) NOT NULL,
    status_platnosci character varying(30) NOT NULL
);


ALTER TABLE public.platnosci OWNER TO student23;

--
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.platnosci_id_platnosci_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.platnosci_id_platnosci_seq OWNER TO student23;

--
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.platnosci_id_platnosci_seq OWNED BY public.platnosci.id_platnosci;


--
-- Name: pozycje_zamowienia; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.pozycje_zamowienia (
    id_zamowienia integer NOT NULL,
    id_produktu integer NOT NULL,
    ilosc integer NOT NULL,
    cena_historyczna numeric(10,2) NOT NULL,
    CONSTRAINT pozycje_zamowienia_cena_historyczna_check CHECK ((cena_historyczna >= (0)::numeric)),
    CONSTRAINT pozycje_zamowienia_ilosc_check CHECK ((ilosc > 0))
);


ALTER TABLE public.pozycje_zamowienia OWNER TO student23;

--
-- Name: producenci; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.producenci (
    id_producenta integer NOT NULL,
    nazwa_producenta character varying(100) NOT NULL,
    kraj_pochodzenia character varying(50)
);


ALTER TABLE public.producenci OWNER TO student23;

--
-- Name: producenci_id_producenta_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.producenci_id_producenta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.producenci_id_producenta_seq OWNER TO student23;

--
-- Name: producenci_id_producenta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.producenci_id_producenta_seq OWNED BY public.producenci.id_producenta;


--
-- Name: produkty; Type: TABLE; Schema: public; Owner: student23
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


ALTER TABLE public.produkty OWNER TO student23;

--
-- Name: produkty_id_produktu_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.produkty_id_produktu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkty_id_produktu_seq OWNER TO student23;

--
-- Name: produkty_id_produktu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.produkty_id_produktu_seq OWNED BY public.produkty.id_produktu;


--
-- Name: wysylki; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.wysylki (
    id_wysylki integer NOT NULL,
    id_zamowienia integer NOT NULL,
    firma_kurierska character varying(100),
    numer_listu character varying(100),
    status_paczki character varying(50)
);


ALTER TABLE public.wysylki OWNER TO student23;

--
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.wysylki_id_wysylki_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wysylki_id_wysylki_seq OWNER TO student23;

--
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.wysylki_id_wysylki_seq OWNED BY public.wysylki.id_wysylki;


--
-- Name: zamowienia; Type: TABLE; Schema: public; Owner: student23
--

CREATE TABLE public.zamowienia (
    id_zamowienia integer NOT NULL,
    id_klienta integer NOT NULL,
    id_kodu integer,
    data_zamowienia timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status_zamowienia character varying(30) NOT NULL
);


ALTER TABLE public.zamowienia OWNER TO student23;

--
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE; Schema: public; Owner: student23
--

CREATE SEQUENCE public.zamowienia_id_zamowienia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zamowienia_id_zamowienia_seq OWNER TO student23;

--
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student23
--

ALTER SEQUENCE public.zamowienia_id_zamowienia_seq OWNED BY public.zamowienia.id_zamowienia;


--
-- Name: kategorie id_kategorii; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.kategorie ALTER COLUMN id_kategorii SET DEFAULT nextval('public.kategorie_id_kategorii_seq'::regclass);


--
-- Name: klienci id_klienta; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.klienci ALTER COLUMN id_klienta SET DEFAULT nextval('public.klienci_id_klienta_seq'::regclass);


--
-- Name: kody_rabatowe id_kodu; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.kody_rabatowe ALTER COLUMN id_kodu SET DEFAULT nextval('public.kody_rabatowe_id_kodu_seq'::regclass);


--
-- Name: opinie id_opinii; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.opinie ALTER COLUMN id_opinii SET DEFAULT nextval('public.opinie_id_opinii_seq'::regclass);


--
-- Name: platnosci id_platnosci; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.platnosci ALTER COLUMN id_platnosci SET DEFAULT nextval('public.platnosci_id_platnosci_seq'::regclass);


--
-- Name: producenci id_producenta; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.producenci ALTER COLUMN id_producenta SET DEFAULT nextval('public.producenci_id_producenta_seq'::regclass);


--
-- Name: produkty id_produktu; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.produkty ALTER COLUMN id_produktu SET DEFAULT nextval('public.produkty_id_produktu_seq'::regclass);


--
-- Name: wysylki id_wysylki; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.wysylki ALTER COLUMN id_wysylki SET DEFAULT nextval('public.wysylki_id_wysylki_seq'::regclass);


--
-- Name: zamowienia id_zamowienia; Type: DEFAULT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.zamowienia ALTER COLUMN id_zamowienia SET DEFAULT nextval('public.zamowienia_id_zamowienia_seq'::regclass);


--
-- Data for Name: kategorie; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.kategorie (id_kategorii, nazwa_kategorii) FROM stdin;
\.


--
-- Data for Name: klienci; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.klienci (id_klienta, imie, nazwisko, email, telefon, miasto, ulica, kod_pocztowy) FROM stdin;
\.


--
-- Data for Name: kody_rabatowe; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.kody_rabatowe (id_kodu, kod_tekstowy, znizka_procentowa) FROM stdin;
\.


--
-- Data for Name: opinie; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.opinie (id_opinii, id_zamowienia, id_produktu, ocena, komentarz) FROM stdin;
\.


--
-- Data for Name: platnosci; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.platnosci (id_platnosci, id_zamowienia, metoda_platnosci, status_platnosci) FROM stdin;
\.


--
-- Data for Name: pozycje_zamowienia; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.pozycje_zamowienia (id_zamowienia, id_produktu, ilosc, cena_historyczna) FROM stdin;
\.


--
-- Data for Name: producenci; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.producenci (id_producenta, nazwa_producenta, kraj_pochodzenia) FROM stdin;
\.


--
-- Data for Name: produkty; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.produkty (id_produktu, id_kategorii, id_producenta, nazwa, opis, cena_aktualna, stan_magazynowy) FROM stdin;
\.


--
-- Data for Name: wysylki; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.wysylki (id_wysylki, id_zamowienia, firma_kurierska, numer_listu, status_paczki) FROM stdin;
\.


--
-- Data for Name: zamowienia; Type: TABLE DATA; Schema: public; Owner: student23
--

COPY public.zamowienia (id_zamowienia, id_klienta, id_kodu, data_zamowienia, status_zamowienia) FROM stdin;
\.


--
-- Name: kategorie_id_kategorii_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.kategorie_id_kategorii_seq', 1, false);


--
-- Name: klienci_id_klienta_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.klienci_id_klienta_seq', 1, false);


--
-- Name: kody_rabatowe_id_kodu_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.kody_rabatowe_id_kodu_seq', 1, false);


--
-- Name: opinie_id_opinii_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.opinie_id_opinii_seq', 1, false);


--
-- Name: platnosci_id_platnosci_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.platnosci_id_platnosci_seq', 1, false);


--
-- Name: producenci_id_producenta_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.producenci_id_producenta_seq', 1, false);


--
-- Name: produkty_id_produktu_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.produkty_id_produktu_seq', 1, false);


--
-- Name: wysylki_id_wysylki_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.wysylki_id_wysylki_seq', 1, false);


--
-- Name: zamowienia_id_zamowienia_seq; Type: SEQUENCE SET; Schema: public; Owner: student23
--

SELECT pg_catalog.setval('public.zamowienia_id_zamowienia_seq', 1, false);


--
-- Name: kategorie kategorie_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.kategorie
    ADD CONSTRAINT kategorie_pkey PRIMARY KEY (id_kategorii);


--
-- Name: klienci klienci_email_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.klienci
    ADD CONSTRAINT klienci_email_key UNIQUE (email);


--
-- Name: klienci klienci_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.klienci
    ADD CONSTRAINT klienci_pkey PRIMARY KEY (id_klienta);


--
-- Name: kody_rabatowe kody_rabatowe_kod_tekstowy_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.kody_rabatowe
    ADD CONSTRAINT kody_rabatowe_kod_tekstowy_key UNIQUE (kod_tekstowy);


--
-- Name: kody_rabatowe kody_rabatowe_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.kody_rabatowe
    ADD CONSTRAINT kody_rabatowe_pkey PRIMARY KEY (id_kodu);


--
-- Name: opinie opinie_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT opinie_pkey PRIMARY KEY (id_opinii);


--
-- Name: opinie opinie_id_zamowienia_id_produktu_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT opinie_id_zamowienia_id_produktu_key UNIQUE (id_zamowienia, id_produktu);


--
-- Name: platnosci platnosci_id_zamowienia_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT platnosci_id_zamowienia_key UNIQUE (id_zamowienia);


--
-- Name: platnosci platnosci_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT platnosci_pkey PRIMARY KEY (id_platnosci);


--
-- Name: pozycje_zamowienia pozycje_zamowienia_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT pozycje_zamowienia_pkey PRIMARY KEY (id_zamowienia, id_produktu);


--
-- Name: producenci producenci_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.producenci
    ADD CONSTRAINT producenci_pkey PRIMARY KEY (id_producenta);


--
-- Name: produkty produkty_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT produkty_pkey PRIMARY KEY (id_produktu);


--
-- Name: wysylki wysylki_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_pkey PRIMARY KEY (id_wysylki);


--
-- Name: wysylki wysylki_id_zamowienia_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_id_zamowienia_key UNIQUE (id_zamowienia);


--
-- Name: wysylki wysylki_numer_listu_key; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT wysylki_numer_listu_key UNIQUE (numer_listu);


--
-- Name: zamowienia zamowienia_pkey; Type: CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT zamowienia_pkey PRIMARY KEY (id_zamowienia);


--
-- Name: idx_platnosci_zamowienie; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_platnosci_zamowienie ON public.platnosci USING btree (id_zamowienia);


--
-- Name: idx_pozycje_produkt; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_pozycje_produkt ON public.pozycje_zamowienia USING btree (id_produktu);


--
-- Name: idx_produkty_kategoria; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_produkty_kategoria ON public.produkty USING btree (id_kategorii);


--
-- Name: idx_produkty_producent; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_produkty_producent ON public.produkty USING btree (id_producenta);


--
-- Name: idx_wysylki_zamowienie; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_wysylki_zamowienie ON public.wysylki USING btree (id_zamowienia);


--
-- Name: idx_zamowienia_klient; Type: INDEX; Schema: public; Owner: student23
--

CREATE INDEX idx_zamowienia_klient ON public.zamowienia USING btree (id_klienta);


--
-- Name: opinie fk_opinie_pozycje; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.opinie
    ADD CONSTRAINT fk_opinie_pozycje FOREIGN KEY (id_zamowienia, id_produktu) REFERENCES public.pozycje_zamowienia(id_zamowienia, id_produktu) ON DELETE CASCADE;


--
-- Name: platnosci fk_platnosci_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.platnosci
    ADD CONSTRAINT fk_platnosci_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- Name: pozycje_zamowienia fk_pozycje_produkty; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT fk_pozycje_produkty FOREIGN KEY (id_produktu) REFERENCES public.produkty(id_produktu) ON DELETE CASCADE;


--
-- Name: pozycje_zamowienia fk_pozycje_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.pozycje_zamowienia
    ADD CONSTRAINT fk_pozycje_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- Name: produkty fk_produkty_kategorie; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT fk_produkty_kategorie FOREIGN KEY (id_kategorii) REFERENCES public.kategorie(id_kategorii) ON DELETE RESTRICT;


--
-- Name: produkty fk_produkty_producenci; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.produkty
    ADD CONSTRAINT fk_produkty_producenci FOREIGN KEY (id_producenta) REFERENCES public.producenci(id_producenta) ON DELETE RESTRICT;


--
-- Name: wysylki fk_wysylki_zamowienia; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.wysylki
    ADD CONSTRAINT fk_wysylki_zamowienia FOREIGN KEY (id_zamowienia) REFERENCES public.zamowienia(id_zamowienia) ON DELETE CASCADE;


--
-- Name: zamowienia fk_zamowienia_klienci; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT fk_zamowienia_klienci FOREIGN KEY (id_klienta) REFERENCES public.klienci(id_klienta) ON DELETE CASCADE;


--
-- Name: zamowienia fk_zamowienia_kody; Type: FK CONSTRAINT; Schema: public; Owner: student23
--

ALTER TABLE ONLY public.zamowienia
    ADD CONSTRAINT fk_zamowienia_kody FOREIGN KEY (id_kodu) REFERENCES public.kody_rabatowe(id_kodu) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict 1kpd3JsDpDHbvbqDAxFBeGDWkcQFmcjGCWZlLzeTTqFCeeVcT7P86DRi7zs6zTr

