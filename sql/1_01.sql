SET search_path TO banks_analysis;

CREATE TABLE states (
	state_fip int PRIMARY KEY,
	state_code char(2),
	state_name text NOT NULL UNIQUE
	);

CREATE TABLE country (
	country_code integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	country_name text NOT NULL UNIQUE
	);

CREATE TABLE bank_class (
	bkclass text PRIMARY KEY,
	description text NOT NULL
	);

CREATE TABLE regulator_codes (
	regagnt text PRIMARY KEY,
	description text NOT NULL
	);

CREATE TABLE branch_service_type (
	service_type integer PRIMARY KEY,
	description text NOT NULL
	);

CREATE TABLE county (
	stcntyfip char(5) PRIMARY KEY,
	state_name text NOT NULL,
	county_fip integer NOT NULL,
	state_fip integer NOT NULL,
	county_name text NOT NULL,

	CONSTRAINT fk_county_state
		FOREIGN KEY (state_fip)
		REFERENCES states(state_fip),

	CONSTRAINT uq_county_state_name
		UNIQUE (state_name, county_name)
	);

CREATE TABLE cbsa (
	cbsa_code integer PRIMARY KEY,
	cbsa_name text UNIQUE
);

CREATE TABLE institution (
	cert integer PRIMARY KEY,
	namefull text NOT NULL,
	asset NUMERIC (20, 2),
	bkclass text NOT NULL,
	country_code integer,
	denovo boolean NOT NULL,
	depdom NUMERIC (20, 2),
	namehcr text,
	regagnt text,
	rssdid text,
	state_fip int,
	institution_location integer CHECK(LENGTH(institution_location::text) <= 5),
	zip integer,
	city text,

	CONSTRAINT fk_institution_bank_class
		FOREIGN KEY (bkclass)
		REFERENCES bank_class(bkclass),

	CONSTRAINT fk_instituion_country
		FOREIGN KEY (country_code)
		REFERENCES country(country_code),

	CONSTRAINT fk_institution_regulator
		FOREIGN KEY (regagnt)
		REFERENCES regulator_codes(regagnt),

	CONSTRAINT fk_institution_state
		FOREIGN KEY (state_fip)
		REFERENCES states(state_fip)
);

CREATE TABLE office (
	uninumber bigint PRIMARY KEY,
	cert integer NOT NULL,
	brnum integer,
	namebr text,
	addressbr text,
	citybr text,
	country_code integer,
	depsumbr NUMERIC(20,2),
	state_fip integer,
	county_fip integer,
	cbsa_code integer,
	zipbr integer,
	service_type integer,
	is_main_office boolean NOT NULL,

	CONSTRAINT fk_office_institution
		FOREIGN KEY (cert)
		REFERENCES institution(cert),

	CONSTRAINT fk_office_country
		FOREIGN KEY (country_code)
		REFERENCES country(country_code),

	CONSTRAINT fk_office_state
		FOREIGN KEY (state_fip)
		REFERENCES states(state_fip),

	CONSTRAINT fk_office_service_type
		FOREIGN KEY (service_type)
		REFERENCES branch_service_type(service_type),

	CONSTRAINT fk_office_cbsa_code
		FOREIGN KEY (cbsa_code)
		REFERENCES cbsa(cbsa_code),

	CONSTRAINT chk_is_main_office
		CHECK (is_main_office IN (TRUE, FALSE))
);


CREATE TABLE geocode_result (
	uninumbr bigint PRIMARY KEY,
	fid bigint,
	longitude NUMERIC (15, 10),
	latitude NUMERIC (15,10),
	loc_name text,
	status text,
	score bigint CHECK(score >= 0 AND score <= 100),
	geocodesou text,
	geocode_ce integer,
	geocode_1 integer,

	CONSTRAINT fk_geocode_office
		FOREIGN KEY (uninumbr)
		REFERENCES office(uninumber)
);
