# 01_Schema Design

Tables:

>
> Tables : [bank_class](#bank_class), [branch_service_type](#branch_service_type), [cbsa](#cbsa), [country](#country)
> [county](#county), [geocode_result](#geocode_result), [institution](#institution), [office](#office),
> [regulator_codes](#regulator_codes), [states](#states)

<details >

#### bank_class

```sql
CREATE TABLE banks_analysis.bank_class (
	bkclass text NOT NULL,
	description text NOT NULL,
	CONSTRAINT bank_class_pkey PRIMARY KEY (bkclass)
);
```

#### branch_service_type
```sql
CREATE TABLE banks_analysis.branch_service_type (
	service_type int4 NOT NULL,
	description text NOT NULL,
	CONSTRAINT branch_service_type_pkey PRIMARY KEY (service_type)
);
```
#### cbsa
```sql
CREATE TABLE banks_analysis.cbsa (
	cbsa_code int4 NOT NULL,
	cbsa_name text NULL,
	CONSTRAINT cbsa_cbsa_name_key UNIQUE (cbsa_name),
	CONSTRAINT cbsa_pkey PRIMARY KEY (cbsa_code)
);
```

#### country
```sql
CREATE TABLE banks_analysis.country (
	country_code int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	country_name text NOT NULL,
	CONSTRAINT country_country_name_key UNIQUE (country_name),
	CONSTRAINT country_pkey PRIMARY KEY (country_code)
);
```

#### county
```sql
CREATE TABLE banks_analysis.county (
	stcntyfip bpchar(5) NOT NULL,
	state_name text NOT NULL,
	county_fip int4 NOT NULL,
	state_fip int4 NOT NULL,
	county_name text NOT NULL,
	CONSTRAINT county_pkey PRIMARY KEY (stcntyfip),
	CONSTRAINT uq_county_state_name UNIQUE (state_name, county_name),
	CONSTRAINT fk_county_state FOREIGN KEY (state_fip) REFERENCES banks_analysis.states(state_fip)
);
```

#### geocode_result
```sql
CREATE TABLE banks_analysis.geocode_result (
	uninumbr int8 NOT NULL,
	fid int8 NULL,
	longitude numeric(15, 10) NULL,
	latitude numeric(15, 10) NULL,
	loc_name text NULL,
	status text NULL,
	score int8 NULL,
	geocodesou text NULL,
	geocode_ce int4 NULL,
	geocode_1 int4 NULL,
	CONSTRAINT geocode_result_pkey PRIMARY KEY (uninumbr),
	CONSTRAINT geocode_result_score_check CHECK (((score >= 0) AND (score <= 100))),
	CONSTRAINT fk_geocode_office FOREIGN KEY (uninumbr) REFERENCES banks_analysis.office(uninumber)
);
```

#### institution
```sql
CREATE TABLE banks_analysis.institution (
	cert int4 NOT NULL,
	namefull text NOT NULL,
	asset numeric(20, 2) NULL,
	bkclass text NOT NULL,
	country_code int4 NULL,
	denovo bool NULL,
	depdom numeric(20, 2) NULL,
	namehcr text NULL,
	regagnt text NULL,
	rssdid text NULL,
	state_fip int4 NULL,
	institution_location int4 NULL,
	zip int4 NULL,
	city text NULL,
	CONSTRAINT institution_institution_location_check CHECK ((length((institution_location)::text) <= 5)),
	CONSTRAINT institution_pkey PRIMARY KEY (cert),
	CONSTRAINT fk_instituion_country FOREIGN KEY (country_code) REFERENCES banks_analysis.country(country_code),
	CONSTRAINT fk_institution_bank_class FOREIGN KEY (bkclass) REFERENCES banks_analysis.bank_class(bkclass),
	CONSTRAINT fk_institution_regulator FOREIGN KEY (regagnt) REFERENCES banks_analysis.regulator_codes(regagnt),
	CONSTRAINT fk_institution_state FOREIGN KEY (state_fip) REFERENCES banks_analysis.states(state_fip)
);
```

#### office
```sql
CREATE TABLE banks_analysis.office (
	uninumber int8 NOT NULL,
	cert int4 NOT NULL,
	brnum int4 NULL,
	namebr text NULL,
	addressbr text NULL,
	citybr text NULL,
	country_code int4 NULL,
	depsumbr numeric(20, 2) NULL,
	state_fip int4 NULL,
	county_fip int4 NULL,
	cbsa_code int4 NULL,
	zipbr int4 NULL,
	service_type int4 NULL,
	is_main_office bool NOT NULL,
	CONSTRAINT chk_is_main_office CHECK ((is_main_office = ANY (ARRAY[true, false]))),
	CONSTRAINT office_pkey PRIMARY KEY (uninumber),
	CONSTRAINT fk_office_cbsa_code FOREIGN KEY (cbsa_code) REFERENCES banks_analysis.cbsa(cbsa_code),
	CONSTRAINT fk_office_country FOREIGN KEY (country_code) REFERENCES banks_analysis.country(country_code),
	CONSTRAINT fk_office_institution FOREIGN KEY (cert) REFERENCES banks_analysis.institution(cert),
	CONSTRAINT fk_office_service_type FOREIGN KEY (service_type) REFERENCES banks_analysis.branch_service_type(service_type),
	CONSTRAINT fk_office_state FOREIGN KEY (state_fip) REFERENCES banks_analysis.states(state_fip)
);
```

#### regulator_codes
```sql
CREATE TABLE banks_analysis.regulator_codes (
	regagnt text NOT NULL,
	description text NOT NULL,
	CONSTRAINT regulator_codes_pkey PRIMARY KEY (regagnt)
);
```

#### states
```sql
CREATE TABLE banks_analysis.states (
	state_fip int4 NOT NULL,
	state_code bpchar(2) NULL,
	state_name text NOT NULL,
	CONSTRAINT states_pkey PRIMARY KEY (state_fip),
	CONSTRAINT states_state_name_key UNIQUE (state_name)
);
```

</details>

# 02_Loading and Cleaning


