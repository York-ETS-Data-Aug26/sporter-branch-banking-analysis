-- I would seperate them by date

CREATE TABLE reporting_period (
	date_of_report date PRIMARY KEY )

CREATE TABLE new_institution (
	institute_id GENERATED IDENTITY PRIMARY KEY ) -- start at one