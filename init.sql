--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cvss3_a; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_a AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss3_a OWNER TO postgres;

--
-- Name: cvss3_ac; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_ac AS ENUM (
    'l',
    'h'
);


ALTER TYPE public.cvss3_ac OWNER TO postgres;

--
-- Name: cvss3_av; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_av AS ENUM (
    'n',
    'a',
    'l',
    'p'
);


ALTER TYPE public.cvss3_av OWNER TO postgres;

--
-- Name: cvss3_c; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_c AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss3_c OWNER TO postgres;

--
-- Name: cvss3_i; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_i AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss3_i OWNER TO postgres;

--
-- Name: cvss3_pr; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_pr AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss3_pr OWNER TO postgres;

--
-- Name: cvss3_s; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_s AS ENUM (
    'u',
    'c'
);


ALTER TYPE public.cvss3_s OWNER TO postgres;

--
-- Name: cvss3_ui; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss3_ui AS ENUM (
    'n',
    'r'
);


ALTER TYPE public.cvss3_ui OWNER TO postgres;

--
-- Name: cvss4_ac; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_ac AS ENUM (
    'l',
    'h'
);


ALTER TYPE public.cvss4_ac OWNER TO postgres;

--
-- Name: cvss4_at; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_at AS ENUM (
    'n',
    'p'
);


ALTER TYPE public.cvss4_at OWNER TO postgres;

--
-- Name: cvss4_av; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_av AS ENUM (
    'n',
    'a',
    'l',
    'p'
);


ALTER TYPE public.cvss4_av OWNER TO postgres;

--
-- Name: cvss4_pr; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_pr AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_pr OWNER TO postgres;

--
-- Name: cvss4_sa; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_sa AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_sa OWNER TO postgres;

--
-- Name: cvss4_sc; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_sc AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_sc OWNER TO postgres;

--
-- Name: cvss4_si; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_si AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_si OWNER TO postgres;

--
-- Name: cvss4_ui; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_ui AS ENUM (
    'n',
    'p',
    'a'
);


ALTER TYPE public.cvss4_ui OWNER TO postgres;

--
-- Name: cvss4_va; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_va AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_va OWNER TO postgres;

--
-- Name: cvss4_vc; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_vc AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_vc OWNER TO postgres;

--
-- Name: cvss4_vi; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cvss4_vi AS ENUM (
    'n',
    'l',
    'h'
);


ALTER TYPE public.cvss4_vi OWNER TO postgres;

--
-- Name: package_transitive(uuid, text, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.package_transitive(sbom_id_param uuid, start_node_id text, relationships_param integer[]) RETURNS TABLE(left_node_id text, right_node_id text)
    LANGUAGE plpgsql
    AS $$
    begin

        return query
        with recursive transitive as (
            select
                package_relates_to_package.left_node_id,
                package_relates_to_package.right_node_id,
                package_relates_to_package.relationship,
                package_relates_to_package.sbom_id
            from
                package_relates_to_package
            where
                package_relates_to_package.right_node_id = start_node_id
                and package_relates_to_package.relationship = any(relationships_param)
                and package_relates_to_package.sbom_id = sbom_id_param
            union
            select
                prp.left_node_id,
                prp.right_node_id,
                prp.relationship,
                prp.sbom_id
            from
                package_relates_to_package prp
                    inner join transitive transitive1
                        on
                            prp.right_node_id = transitive1.left_node_id
                            and prp.relationship = any(relationships_param)
                            and prp.sbom_id = transitive1.sbom_id
        )
        select
            cast(transitive.left_node_id as text),
            cast(transitive.right_node_id as text)
        from
            transitive;
end;
$$;


ALTER FUNCTION public.package_transitive(sbom_id_param uuid, start_node_id text, relationships_param integer[]) OWNER TO postgres;

--
-- Name: qualified_package_transitive(uuid, uuid, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.qualified_package_transitive(sbom_id_param uuid, start_package_id uuid, relationships_param integer[]) RETURNS TABLE(left_package_id uuid, right_package_id uuid)
    LANGUAGE plpgsql
    AS $$
begin

    return query
    select
        left_id.qualified_package_id,
        right_id.qualified_package_id
    from (
        select
            node_id
        from
            sbom_package_purl_ref AS source
        where
            source.qualified_package_id = start_package_id
            and
            source.sbom_id = sbom_id_param
    ) AS t

     cross join lateral package_transitive(sbom_id_param, t.node_id, relationships_param) as result
     join sbom_package_purl_ref as left_id
            on
                left_id.node_id = result.left_node_id
                and left_id.sbom_id = sbom_id_param
     join sbom_package_purl_ref as right_id
            on
                right_id.node_id = result.right_node_id
                and right_id.sbom_id = sbom_id_param
    ;

end
$$;


ALTER FUNCTION public.qualified_package_transitive(sbom_id_param uuid, start_package_id uuid, relationships_param integer[]) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: advisory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.advisory (
    issuer_id integer,
    published timestamp with time zone,
    modified timestamp with time zone,
    withdrawn timestamp with time zone,
    identifier character varying NOT NULL,
    location character varying NOT NULL,
    sha256 character varying NOT NULL,
    title character varying,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.advisory OWNER TO postgres;

--
-- Name: advisory_vulnerability; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.advisory_vulnerability (
    vulnerability_id integer NOT NULL,
    title character varying,
    summary character varying,
    description character varying,
    discovery_date timestamp with time zone,
    release_date timestamp with time zone,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.advisory_vulnerability OWNER TO postgres;

--
-- Name: affected_package_version_range; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.affected_package_version_range (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_version_range_id integer NOT NULL,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.affected_package_version_range OWNER TO postgres;

--
-- Name: affected_package_version_range_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.affected_package_version_range_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.affected_package_version_range_id_seq OWNER TO postgres;

--
-- Name: affected_package_version_range_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.affected_package_version_range_id_seq OWNED BY public.affected_package_version_range.id;


--
-- Name: cpe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cpe (
    id integer NOT NULL,
    part character varying,
    vendor character varying,
    product character varying,
    version character varying,
    update character varying,
    edition character varying,
    language character varying,
    sw_edition character varying,
    target_sw character varying,
    target_hw character varying,
    other character varying
);


ALTER TABLE public.cpe OWNER TO postgres;

--
-- Name: cpe_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cpe_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cpe_id_seq OWNER TO postgres;

--
-- Name: cpe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cpe_id_seq OWNED BY public.cpe.id;


--
-- Name: cvss3; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cvss3 (
    vulnerability_id integer NOT NULL,
    minor_version integer NOT NULL,
    av public.cvss3_av NOT NULL,
    ac public.cvss3_ac NOT NULL,
    pr public.cvss3_pr NOT NULL,
    ui public.cvss3_ui NOT NULL,
    s public.cvss3_s NOT NULL,
    c public.cvss3_c NOT NULL,
    i public.cvss3_i NOT NULL,
    a public.cvss3_a NOT NULL,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.cvss3 OWNER TO postgres;

--
-- Name: cvss4; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cvss4 (
    vulnerability_id integer NOT NULL,
    minor_version integer NOT NULL,
    av public.cvss4_av NOT NULL,
    ac public.cvss4_ac NOT NULL,
    at public.cvss4_at NOT NULL,
    pr public.cvss4_pr NOT NULL,
    ui public.cvss4_ui NOT NULL,
    vc public.cvss4_vc NOT NULL,
    vi public.cvss4_vi NOT NULL,
    va public.cvss4_va NOT NULL,
    sc public.cvss4_sc NOT NULL,
    si public.cvss4_si NOT NULL,
    sa public.cvss4_sa NOT NULL,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.cvss4 OWNER TO postgres;

--
-- Name: fixed_package_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fixed_package_version (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_version_id uuid NOT NULL,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.fixed_package_version OWNER TO postgres;

--
-- Name: fixed_package_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fixed_package_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fixed_package_version_id_seq OWNER TO postgres;

--
-- Name: fixed_package_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fixed_package_version_id_seq OWNED BY public.fixed_package_version.id;


--
-- Name: importer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.importer (
    name character varying NOT NULL,
    revision uuid NOT NULL,
    state integer NOT NULL,
    last_change timestamp with time zone,
    last_error character varying,
    last_success timestamp with time zone,
    last_run timestamp with time zone,
    continuation jsonb,
    configuration jsonb
);


ALTER TABLE public.importer OWNER TO postgres;

--
-- Name: importer_report; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.importer_report (
    id uuid NOT NULL,
    importer character varying NOT NULL,
    creation timestamp with time zone NOT NULL,
    error character varying,
    report jsonb NOT NULL
);


ALTER TABLE public.importer_report OWNER TO postgres;

--
-- Name: not_affected_package_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.not_affected_package_version (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_version_id uuid NOT NULL,
    advisory_id uuid NOT NULL
);


ALTER TABLE public.not_affected_package_version OWNER TO postgres;

--
-- Name: not_affected_package_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.not_affected_package_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.not_affected_package_version_id_seq OWNER TO postgres;

--
-- Name: not_affected_package_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.not_affected_package_version_id_seq OWNED BY public.not_affected_package_version.id;


--
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization (
    id integer NOT NULL,
    name character varying NOT NULL,
    cpe_key character varying,
    website character varying
);


ALTER TABLE public.organization OWNER TO postgres;

--
-- Name: organization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organization_id_seq OWNER TO postgres;

--
-- Name: organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_id_seq OWNED BY public.organization.id;


--
-- Name: package; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.package (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    type character varying NOT NULL,
    namespace character varying,
    name character varying NOT NULL
);


ALTER TABLE public.package OWNER TO postgres;

--
-- Name: package_relates_to_package; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.package_relates_to_package (
    left_node_id character varying NOT NULL,
    relationship integer NOT NULL,
    right_node_id character varying NOT NULL,
    sbom_id uuid NOT NULL
);


ALTER TABLE public.package_relates_to_package OWNER TO postgres;

--
-- Name: package_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.package_version (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    package_id uuid NOT NULL,
    version character varying NOT NULL
);


ALTER TABLE public.package_version OWNER TO postgres;

--
-- Name: package_version_range; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.package_version_range (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    package_id uuid NOT NULL,
    start character varying NOT NULL,
    "end" character varying NOT NULL
);


ALTER TABLE public.package_version_range OWNER TO postgres;

--
-- Name: package_version_range_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.package_version_range_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.package_version_range_id_seq OWNER TO postgres;

--
-- Name: package_version_range_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.package_version_range_id_seq OWNED BY public.package_version_range.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying NOT NULL,
    vendor_id integer
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_id_seq OWNER TO postgres;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: product_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_version (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    product_id integer NOT NULL,
    sbom_id uuid,
    version character varying NOT NULL
);


ALTER TABLE public.product_version OWNER TO postgres;

--
-- Name: product_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_version_id_seq OWNER TO postgres;

--
-- Name: product_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_version_id_seq OWNED BY public.product_version.id;


--
-- Name: qualified_package; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.qualified_package (
    id uuid NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    package_version_id uuid NOT NULL,
    qualifiers jsonb NOT NULL
);


ALTER TABLE public.qualified_package OWNER TO postgres;

--
-- Name: relationship; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.relationship (
    id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.relationship OWNER TO postgres;

--
-- Name: sbom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sbom (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    location character varying NOT NULL,
    document_id character varying NOT NULL,
    sha256 character varying NOT NULL,
    published timestamp with time zone,
    authors character varying[]
);


ALTER TABLE public.sbom OWNER TO postgres;

--
-- Name: sbom_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sbom_node (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.sbom_node OWNER TO postgres;

--
-- Name: sbom_package; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sbom_package (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL
);


ALTER TABLE public.sbom_package OWNER TO postgres;

--
-- Name: sbom_package_cpe_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sbom_package_cpe_ref (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    cpe_id integer NOT NULL
);


ALTER TABLE public.sbom_package_cpe_ref OWNER TO postgres;

--
-- Name: sbom_package_purl_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sbom_package_purl_ref (
    sbom_id uuid NOT NULL,
    node_id character varying NOT NULL,
    qualified_package_id uuid NOT NULL
);


ALTER TABLE public.sbom_package_purl_ref OWNER TO postgres;

--
-- Name: seaql_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seaql_migrations (
    version character varying NOT NULL,
    applied_at bigint NOT NULL
);


ALTER TABLE public.seaql_migrations OWNER TO postgres;

--
-- Name: vulnerability; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vulnerability (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    identifier character varying NOT NULL,
    title character varying,
    published timestamp with time zone,
    modified timestamp with time zone,
    withdrawn timestamp with time zone
);


ALTER TABLE public.vulnerability OWNER TO postgres;

--
-- Name: vulnerability_description; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vulnerability_description (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    lang character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.vulnerability_description OWNER TO postgres;

--
-- Name: vulnerability_description_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vulnerability_description_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vulnerability_description_id_seq OWNER TO postgres;

--
-- Name: vulnerability_description_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vulnerability_description_id_seq OWNED BY public.vulnerability_description.id;


--
-- Name: vulnerability_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vulnerability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vulnerability_id_seq OWNER TO postgres;

--
-- Name: vulnerability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vulnerability_id_seq OWNED BY public.vulnerability.id;


--
-- Name: affected_package_version_range id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affected_package_version_range ALTER COLUMN id SET DEFAULT nextval('public.affected_package_version_range_id_seq'::regclass);


--
-- Name: cpe id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cpe ALTER COLUMN id SET DEFAULT nextval('public.cpe_id_seq'::regclass);


--
-- Name: fixed_package_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_package_version ALTER COLUMN id SET DEFAULT nextval('public.fixed_package_version_id_seq'::regclass);


--
-- Name: not_affected_package_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.not_affected_package_version ALTER COLUMN id SET DEFAULT nextval('public.not_affected_package_version_id_seq'::regclass);


--
-- Name: organization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT nextval('public.organization_id_seq'::regclass);


--
-- Name: package_version_range id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_version_range ALTER COLUMN id SET DEFAULT nextval('public.package_version_range_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Name: product_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_version ALTER COLUMN id SET DEFAULT nextval('public.product_version_id_seq'::regclass);


--
-- Name: vulnerability id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vulnerability ALTER COLUMN id SET DEFAULT nextval('public.vulnerability_id_seq'::regclass);


--
-- Name: vulnerability_description id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vulnerability_description ALTER COLUMN id SET DEFAULT nextval('public.vulnerability_description_id_seq'::regclass);


--
-- Data for Name: advisory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.advisory (issuer_id, published, modified, withdrawn, identifier, location, sha256, title, id) FROM stdin;
\.


--
-- Data for Name: advisory_vulnerability; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.advisory_vulnerability (vulnerability_id, title, summary, description, discovery_date, release_date, advisory_id) FROM stdin;
\.


--
-- Data for Name: affected_package_version_range; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.affected_package_version_range (id, vulnerability_id, package_version_range_id, advisory_id) FROM stdin;
\.


--
-- Data for Name: cpe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cpe (id, part, vendor, product, version, update, edition, language, sw_edition, target_sw, target_hw, other) FROM stdin;
\.


--
-- Data for Name: cvss3; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cvss3 (vulnerability_id, minor_version, av, ac, pr, ui, s, c, i, a, advisory_id) FROM stdin;
\.


--
-- Data for Name: cvss4; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cvss4 (vulnerability_id, minor_version, av, ac, at, pr, ui, vc, vi, va, sc, si, sa, advisory_id) FROM stdin;
\.


--
-- Data for Name: fixed_package_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fixed_package_version (id, vulnerability_id, package_version_id, advisory_id) FROM stdin;
\.


--
-- Data for Name: importer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.importer (name, revision, state, last_change, last_error, last_success, last_run, continuation, configuration) FROM stdin;
redhat-sbom	f90077e5-7451-4cb8-ae59-4bee40d1168e	0	2024-06-07 14:09:56.84723-03	\N	\N	\N	\N	{"sbom": {"keys": ["https://access.redhat.com/security/data/97f5eac4.txt#77E79ABE93673533ED09EBE2DCE3823597F5EAC4"], "period": "5m", "source": "https://access.redhat.com/security/data/sbom/beta/", "disabled": true, "description": "All Red Hat SBOMs", "v3Signatures": true}}
redhat-csaf	6c29d32d-ed51-4e3d-bb4f-bd1d8641c17d	0	2024-06-07 14:09:56.850366-03	\N	\N	\N	\N	{"csaf": {"period": "5m", "source": "redhat.com", "disabled": true, "description": "All Red Hat CSAF data", "v3Signatures": true}}
redhat-csaf-vex-2024	d85796c1-b083-40f0-a7b5-ad90d8fc07ca	0	2024-06-07 14:09:56.852864-03	\N	\N	\N	\N	{"csaf": {"period": "5m", "source": "redhat.com", "disabled": true, "description": "Red Hat VEX files from 2024", "onlyPatterns": ["^cve-2024-"], "v3Signatures": true}}
cve	908050b7-efef-4afd-bded-14188fa90146	0	2024-06-07 14:09:56.855392-03	\N	\N	\N	\N	{"cve": {"period": "5m", "source": "https://github.com/CVEProject/cvelistV5", "disabled": true, "description": "CVE List V5"}}
cve-from-2024	f7117eb6-79de-48da-ba7e-8c7c17bb7c58	0	2024-06-07 14:09:56.857835-03	\N	\N	\N	\N	{"cve": {"period": "5m", "source": "https://github.com/CVEProject/cvelistV5", "disabled": true, "startYear": 2024, "description": "CVE List V5 (starting 2024)"}}
osv-pypa	d60fa19c-ef41-4d33-8ae8-b76764ee4edc	0	2024-06-07 14:09:56.860405-03	\N	\N	\N	\N	{"osv": {"path": "vulns", "period": "5m", "source": "https://github.com/pypa/advisory-database", "disabled": true, "description": "Python Packaging Advisory Database"}}
osv-psf	5eac3838-8a76-4285-9e6c-474160fca0ad	0	2024-06-07 14:09:56.862823-03	\N	\N	\N	\N	{"osv": {"path": "advisories", "period": "5m", "source": "https://github.com/psf/advisory-database", "disabled": true, "description": "Python Software Foundation Advisory Database"}}
osv-r	99612d2b-04a7-4f59-81a8-e5c476f594d0	0	2024-06-07 14:09:56.865919-03	\N	\N	\N	\N	{"osv": {"path": "vulns", "period": "5m", "source": "https://github.com/RConsortium/r-advisory-database", "disabled": true, "description": "RConsortium Advisory Database"}}
osv-oss-fuzz	9d4a6f81-ded8-4545-9a6c-c6520e65f490	0	2024-06-07 14:09:56.868917-03	\N	\N	\N	\N	{"osv": {"path": "vulns", "period": "5m", "source": "https://github.com/google/oss-fuzz-vulns", "disabled": true, "description": "OSS-Fuzz vulnerabilities"}}
\.


--
-- Data for Name: importer_report; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.importer_report (id, importer, creation, error, report) FROM stdin;
\.


--
-- Data for Name: not_affected_package_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.not_affected_package_version (id, vulnerability_id, package_version_id, advisory_id) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, cpe_key, website) FROM stdin;
\.


--
-- Data for Name: package; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.package (id, "timestamp", type, namespace, name) FROM stdin;
\.


--
-- Data for Name: package_relates_to_package; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.package_relates_to_package (left_node_id, relationship, right_node_id, sbom_id) FROM stdin;
\.


--
-- Data for Name: package_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.package_version (id, "timestamp", package_id, version) FROM stdin;
\.


--
-- Data for Name: package_version_range; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.package_version_range (id, "timestamp", package_id, start, "end") FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, name, vendor_id) FROM stdin;
\.


--
-- Data for Name: product_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_version (id, "timestamp", product_id, sbom_id, version) FROM stdin;
\.


--
-- Data for Name: qualified_package; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.qualified_package (id, "timestamp", package_version_id, qualifiers) FROM stdin;
\.


--
-- Data for Name: relationship; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.relationship (id, description) FROM stdin;
0	ContainedBy
1	DependencyOf
2	DevDependencyOf
3	OptionalDependencyOf
4	ProvidedDependencyOf
5	TestDependencyOf
6	RuntimeDependencyOf
7	ExampleOf
8	GeneratedFrom
9	AncestorOf
10	VariantOf
11	BuildToolOf
12	DevToolOf
13	DescribedBy
\.


--
-- Data for Name: sbom; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sbom (sbom_id, node_id, location, document_id, sha256, published, authors) FROM stdin;
\.


--
-- Data for Name: sbom_node; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sbom_node (sbom_id, node_id, name) FROM stdin;
\.


--
-- Data for Name: sbom_package; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sbom_package (sbom_id, node_id) FROM stdin;
\.


--
-- Data for Name: sbom_package_cpe_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sbom_package_cpe_ref (sbom_id, node_id, cpe_id) FROM stdin;
\.


--
-- Data for Name: sbom_package_purl_ref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sbom_package_purl_ref (sbom_id, node_id, qualified_package_id) FROM stdin;
\.


--
-- Data for Name: seaql_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seaql_migrations (version, applied_at) FROM stdin;
m0000010_create_cvss3_enums	1717780190
m0000020_create_cvss4_enums	1717780190
m0000022_create_organization	1717780190
m0000030_create_sbom	1717780190
m0000040_create_vulnerability	1717780190
m0000050_create_vulnerability_description	1717780190
m0000060_create_advisory	1717780190
m0000070_create_cvss3	1717780190
m0000080_create_cvss4	1717780190
m0000090_create_advisory_vulnerability	1717780190
m0000100_create_package	1717780190
m0000110_create_cpe	1717780190
m0000120_create_package_version	1717780190
m0000130_create_qualified_package	1717780190
m0000140_create_package_version_range	1717780190
m0000150_create_affected_package_version_range	1717780190
m0000160_create_fixed_package_version	1717780190
m0000170_create_not_affected_package_version	1717780190
m0000210_create_relationship	1717780190
m0000220_create_package_relates_to_package	1717780190
m0000230_create_qualified_package_transitive_function	1717780190
m0000240_create_importer	1717780190
m0000250_create_sbom_package	1717780190
m0000260_sbom_package_cpe_ref	1717780190
m0000270_sbom_package_purl_ref	1717780190
m0000280_add_advisory_vulnerability_meta	1717780190
m0000290_create_product	1717780190
m0000300_create_product_version	1717780190
m0000310_alter_advisory_primary_key	1717780190
\.


--
-- Data for Name: vulnerability; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vulnerability (id, "timestamp", identifier, title, published, modified, withdrawn) FROM stdin;
\.


--
-- Data for Name: vulnerability_description; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vulnerability_description (id, vulnerability_id, "timestamp", lang, description) FROM stdin;
\.


--
-- Name: affected_package_version_range_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.affected_package_version_range_id_seq', 1, false);


--
-- Name: cpe_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cpe_id_seq', 1, false);


--
-- Name: fixed_package_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fixed_package_version_id_seq', 1, false);


--
-- Name: not_affected_package_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.not_affected_package_version_id_seq', 1, false);


--
-- Name: organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_id_seq', 1, false);


--
-- Name: package_version_range_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.package_version_range_id_seq', 1, false);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 1, false);


--
-- Name: product_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_version_id_seq', 1, false);


--
-- Name: vulnerability_description_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vulnerability_description_id_seq', 1, false);


--
-- Name: vulnerability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vulnerability_id_seq', 1, false);


--
-- Name: advisory advisory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_pkey PRIMARY KEY (id);


--
-- Name: advisory advisory_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_uuid_key UNIQUE (id);


--
-- Name: affected_package_version_range affected_package_version_range_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affected_package_version_range
    ADD CONSTRAINT affected_package_version_range_pkey PRIMARY KEY (id);


--
-- Name: cpe cpe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cpe
    ADD CONSTRAINT cpe_pkey PRIMARY KEY (id);


--
-- Name: fixed_package_version fixed_package_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_package_version
    ADD CONSTRAINT fixed_package_version_pkey PRIMARY KEY (id);


--
-- Name: importer importer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importer
    ADD CONSTRAINT importer_pkey PRIMARY KEY (name);


--
-- Name: importer_report importer_report_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importer_report
    ADD CONSTRAINT importer_report_pkey PRIMARY KEY (id);


--
-- Name: not_affected_package_version not_affected_package_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.not_affected_package_version
    ADD CONSTRAINT not_affected_package_version_pkey PRIMARY KEY (id);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: package package_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_pkey PRIMARY KEY (id);


--
-- Name: package_relates_to_package package_relates_to_package_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_pkey PRIMARY KEY (sbom_id, left_node_id, relationship, right_node_id);


--
-- Name: package package_type_namespace_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_type_namespace_name_key UNIQUE (type, namespace, name);


--
-- Name: package_version package_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_version
    ADD CONSTRAINT package_version_pkey PRIMARY KEY (id);


--
-- Name: package_version_range package_version_range_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_version_range
    ADD CONSTRAINT package_version_range_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_version product_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_pkey PRIMARY KEY (id);


--
-- Name: qualified_package qualified_package_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qualified_package
    ADD CONSTRAINT qualified_package_pkey PRIMARY KEY (id);


--
-- Name: relationship relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.relationship
    ADD CONSTRAINT relationship_pkey PRIMARY KEY (id);


--
-- Name: sbom_node sbom_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_node
    ADD CONSTRAINT sbom_node_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_pkey PRIMARY KEY (sbom_id, node_id, cpe_id);


--
-- Name: sbom_package sbom_package_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package
    ADD CONSTRAINT sbom_package_pkey PRIMARY KEY (sbom_id, node_id);


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_pkey PRIMARY KEY (sbom_id, node_id, qualified_package_id);


--
-- Name: sbom sbom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom
    ADD CONSTRAINT sbom_pkey PRIMARY KEY (sbom_id);


--
-- Name: seaql_migrations seaql_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seaql_migrations
    ADD CONSTRAINT seaql_migrations_pkey PRIMARY KEY (version);


--
-- Name: vulnerability_description vulnerability_description_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vulnerability_description
    ADD CONSTRAINT vulnerability_description_pkey PRIMARY KEY (id);


--
-- Name: vulnerability vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vulnerability
    ADD CONSTRAINT vulnerability_pkey PRIMARY KEY (id);


--
-- Name: by_pid_v; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX by_pid_v ON public.package_version USING btree (package_id, version);


--
-- Name: by_productid_v; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX by_productid_v ON public.product_version USING btree (product_id, version);


--
-- Name: by_pvid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX by_pvid ON public.qualified_package USING btree (package_version_id);


--
-- Name: advisory advisory_issuer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advisory
    ADD CONSTRAINT advisory_issuer_id_fkey FOREIGN KEY (issuer_id) REFERENCES public.organization(id);


--
-- Name: advisory_vulnerability advisory_vulnerability_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.advisory_vulnerability
    ADD CONSTRAINT advisory_vulnerability_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id);


--
-- Name: affected_package_version_range affected_package_version_range_package_version_range_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affected_package_version_range
    ADD CONSTRAINT affected_package_version_range_package_version_range_id_fkey FOREIGN KEY (package_version_range_id) REFERENCES public.package_version_range(id);


--
-- Name: affected_package_version_range affected_package_version_range_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affected_package_version_range
    ADD CONSTRAINT affected_package_version_range_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id);


--
-- Name: fixed_package_version fixed_package_version_package_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_package_version
    ADD CONSTRAINT fixed_package_version_package_version_id_fkey FOREIGN KEY (package_version_id) REFERENCES public.package_version(id);


--
-- Name: fixed_package_version fixed_package_version_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_package_version
    ADD CONSTRAINT fixed_package_version_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id);


--
-- Name: importer_report importer_report_importer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.importer_report
    ADD CONSTRAINT importer_report_importer_fkey FOREIGN KEY (importer) REFERENCES public.importer(name) ON DELETE CASCADE;


--
-- Name: not_affected_package_version not_affected_package_version_package_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.not_affected_package_version
    ADD CONSTRAINT not_affected_package_version_package_version_id_fkey FOREIGN KEY (package_version_id) REFERENCES public.package_version(id);


--
-- Name: not_affected_package_version not_affected_package_version_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.not_affected_package_version
    ADD CONSTRAINT not_affected_package_version_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id);


--
-- Name: package_relates_to_package package_relates_to_package_relationship_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_relationship_fkey FOREIGN KEY (relationship) REFERENCES public.relationship(id);


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id);


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_left_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_left_node_id_fkey FOREIGN KEY (sbom_id, left_node_id) REFERENCES public.sbom_node(sbom_id, node_id);


--
-- Name: package_relates_to_package package_relates_to_package_sbom_id_right_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_relates_to_package
    ADD CONSTRAINT package_relates_to_package_sbom_id_right_node_id_fkey FOREIGN KEY (sbom_id, right_node_id) REFERENCES public.sbom_node(sbom_id, node_id);


--
-- Name: package_version package_version_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_version
    ADD CONSTRAINT package_version_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id) ON DELETE CASCADE;


--
-- Name: package_version_range package_version_range_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.package_version_range
    ADD CONSTRAINT package_version_range_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id) ON DELETE CASCADE;


--
-- Name: product product_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.organization(id);


--
-- Name: product_version product_version_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_version product_version_sbom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_version
    ADD CONSTRAINT product_version_sbom_id_fkey FOREIGN KEY (sbom_id) REFERENCES public.sbom(sbom_id) ON DELETE SET NULL;


--
-- Name: qualified_package qualified_package_package_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.qualified_package
    ADD CONSTRAINT qualified_package_package_version_id_fkey FOREIGN KEY (package_version_id) REFERENCES public.package_version(id) ON DELETE CASCADE;


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_cpe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_cpe_id_fkey FOREIGN KEY (cpe_id) REFERENCES public.cpe(id);


--
-- Name: sbom_package_cpe_ref sbom_package_cpe_ref_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_cpe_ref
    ADD CONSTRAINT sbom_package_cpe_ref_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_package(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_qualified_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_qualified_package_id_fkey FOREIGN KEY (qualified_package_id) REFERENCES public.qualified_package(id);


--
-- Name: sbom_package_purl_ref sbom_package_purl_ref_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package_purl_ref
    ADD CONSTRAINT sbom_package_purl_ref_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_package(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom_package sbom_package_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom_package
    ADD CONSTRAINT sbom_package_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_node(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: sbom sbom_sbom_id_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sbom
    ADD CONSTRAINT sbom_sbom_id_node_id_fkey FOREIGN KEY (sbom_id, node_id) REFERENCES public.sbom_node(sbom_id, node_id) ON DELETE CASCADE;


--
-- Name: vulnerability_description vulnerability_description_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vulnerability_description
    ADD CONSTRAINT vulnerability_description_vulnerability_id_fkey FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerability(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

