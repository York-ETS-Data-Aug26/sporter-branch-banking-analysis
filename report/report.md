# 01_Schema Design

### Tables:

>
> Tables : [bank_class](#bank_class), [branch_service_type](#branch_service_type), [cbsa](#cbsa), [country](#country)
> [county](#county), [geocode_result](#geocode_result), [institution](#institution), [office](#office),
> [regulator_codes](#regulator_codes), [states](#states)

<details >

#### [bank_class](#Tables)

```sql
CREATE TABLE banks_analysis.bank_class (
	bkclass text NOT NULL,
	description text NOT NULL,
	CONSTRAINT bank_class_pkey PRIMARY KEY (bkclass)
);
```

#### [branch_service_type](#Tables)
```sql
CREATE TABLE banks_analysis.branch_service_type (
	service_type int4 NOT NULL,
	description text NOT NULL,
	CONSTRAINT branch_service_type_pkey PRIMARY KEY (service_type)
);
```
#### [cbsa](#Tables)
```sql
CREATE TABLE banks_analysis.cbsa (
	cbsa_code int4 NOT NULL,
	cbsa_name text NULL,
	CONSTRAINT cbsa_cbsa_name_key UNIQUE (cbsa_name),
	CONSTRAINT cbsa_pkey PRIMARY KEY (cbsa_code)
);
```

#### [country](#Tables)
```sql
CREATE TABLE banks_analysis.country (
	country_code int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	country_name text NOT NULL,
	CONSTRAINT country_country_name_key UNIQUE (country_name),
	CONSTRAINT country_pkey PRIMARY KEY (country_code)
);
```

#### [county](#Tables)
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

#### [geocode_result](#Tables)
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

#### [institution](#Tables)
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

#### [office](#Tables)
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

#### [regulator_codes](#Tables)
```sql
CREATE TABLE banks_analysis.regulator_codes (
	regagnt text NOT NULL,
	description text NOT NULL,
	CONSTRAINT regulator_codes_pkey PRIMARY KEY (regagnt)
);
```

#### [states](#Tables)
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

### Indexes
>
> Indexes that I created can be found **[here](../sql/1_02.sql)**

# 02_Loading and Cleaning

### Cleaning Information
Most of the text values that were **fully** numbers were turned into integers, bigints,
or numericals. Where it was 0 or 1's that's where I turned them into booleans for determining
Main branches or just offices. I had to pad `state_fip` and `county_fip` as I derived
them from `stncnty` for the branches. All of the text values were trimmed whether they were being turned
to numerical values or booleans.

### Reconciliation

Can be found **[here](../sql/2_02.sql)**

For what I think happened in each case, though in some cases I believe that
it has to do with the repdte column:

7213	Citibank, National Association
17985	First Hawaiian Bank
18053	Bank of Hawaii
33653	Bank of China: They created a new bank where all their office deposits were put into another bank instituion under the same name
33652	Bank of China: explained above
28100	Iberiabank: 
20884	Bank of Guam
5615	Chambers Bank
57815	Banesco USA
30692	BankPacific, Ltd:
33681	Unknown: Bank of Baroda: Only had one office
4170	The First National Bank and Trust Company of Okmulgee
1100	Peoples State Bank of Plainview

### Re-runability 

# 03_Derived Structures

| Type | Name                     | Description/Reasoning                                                                                                                                        |
|------|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| view | office_deposits          | Didn't want to copy information as it could affect performance, but is generally want information someone would want to look at from an analysis standpoint. |
| view | institution_summary      | Similiar to the institution table, but contains some of the office elements as well. (Surface level)                                                         | * but is generally want information someone would want to look at from an analysis standpoint. |                          |                                                                                                                                                              |
                                                                                                                                                     |
| view | institution_market_share | Deposit market share per institution per metropolitan area - institution_market_share                                                                        |
| view | data_quality_summary     | Using normalized values, this gives a report when needed of table values. View because wouldn't use consistently.                                            |

# DIRECTED ANALYSIS

Keys, dependencies, and redundancy. 
Which columns can serve as a primary key for an office, 
and which for an institution? Which columns hold the same value for every row in the file? 
Which are fully determined by another column? Which describe an individual office rather than the 
institution, despite a name that suggests otherwise? 

### Keys, dependencies, and redundancy

For the primary keys, since they have to be unique and non-repetitive, I chose distinctive columns that
corresponded to the tables (Office and Institution)[^1].

[^1]: The primary keys could also be made in combination with another column and that
can then be made distinctive. They would both have to be non-null as well.

- Office : **`UNINUMBR`**
- Institution : **`CERT`**

~~~~sql
-- for office primary key
SELECT
    count(*) as total_rows,
    count(DISTINCT uninumbr) as distinct_uninumbr,
    count(*) - count(Distinct uninumbr) as duplicate_count
FROM staging s;
~~~~
~~~~sql
-- for institution primary key
SELECT
    count(*) as total_rows,
    count(DISTINCT cert) as distinct_cert,
    count(*) - count(DISTINCT cert) as duplicate_count
FROM staging s;
~~~~

**The column(s) that hold the same value for every row in the file were:**

`REPDTE` is constant through all rows as it appears that all the reports in the initial
file were all formulated on the same day. It's not helpful when it comes to distinguishing office vs.
institution. 

| COlUMN_NAME | DESCRIPTION                                                                            |
|-------------|----------------------------------------------------------------------------------------|
| REPDTE      | Not defined in the FDIC variable list. The reporting date of the survey                |
| DENOVO      | A flag used to indicate whether an Institution is a new Institution (not a Recharter). |

~~~~sql
-- code that can be repeated for each column
SELECT
    count(DISTINCT repdte)
FROM staging s;

SELECT count(*) AS row_count,
	count(DISTINCT s.repdte ) AS distinct_values,
	min(s.repdte ) AS value,
	max(s.repdte) AS value2
FROM staging s;
~~~~

**The column(s) that were fully determined by another column from normalization:**

| COLUMN_NAME | DESCRIPTION                                                        | DERIVED_FROM |
|-------------|--------------------------------------------------------------------|--------------|
| STATE_FIP   | 2 digit code to determine what states the branches were located in | STCNTYBR     |
| COUNTY_FIP  | 3 digit code to determine what county the branches were located in | STCNTYBR     |

**The column(s) that were fully determined by another column from staging:**


| COLUMN_NAME | DERIVED_FROM |
|-------------|--------------|
| CBSANAMB    | CBSABR       |
| STNAMEBR    | STALPBR      |
| CNTYNAMB    | STCNTYBR     |
| STALPBR     | STCNTYBR     |

[04_01 Evidence](../sql/4_01.sql)

### Branch networks and deposits

- Wells Fargo
- Chase Bank
- Bank of America

Interestingly, the office count between the top 10 and top 100
corresponded with their office market share.

[4_02 Evidence](../sql/4_02.sql)

### Local markets and where deposits sit.

>
> I applied the minimum threshold as 1,000,000 (million).
> I understand that this is subjective as numbers began to skew
> and there wasn't much data to select from


The number one result was: New York-Newark-Jersey City, NY-NJ-PA

That made sense on the surface (seeing New York) but it also looked
like a combination of boroughs.

[4_03 Evidence](../sql/4_03.sql)

### The geocoded coordinates

There were three values in the status column
- T
- M
- NULL (I decided to make this null as I didn't want to assume anything).

Where the score is 0, the status is NULL

### The geocoded coordinates

The lengths of the latitudes and longitudes:
min_lat: 5.307	
max_lat: 71.2926190000	

min_long: -170.7195770000
max_long: 170.855

They vary in precision.

-- duplicate pairs 1,4768
-- offices_sharing 3,423
-- most_in_same 19
-- least in same 2

Matches & Status:
49	
1654	T
93022	M

# 05_Open-Ended_Analysis

1. I would seperate them by date
2. Would have old bank history from previous year, so cert from the previous year would hold
3. Add a timestamp to the repdte column. Different times around the US
Advantages:

- Can see merges and take-overs of banks.
- Accurate snapshot of the market
- How reporting times affect the numbers

Disadvantages:

- The querying of data would be large
- Dealing with time changes would be difficult
- A merge could happen right before the report
  - and something could happen with the generation of the report

