create database data_loading_practice;

create schema data_loading_schema;

create or replace transient table customer_csv (
	customer_pk number(38,0),
	salutation varchar(10),
	first_name varchar(20),
	last_name varchar(30),
	gender varchar(1),
	marital_status varchar(1),
	day_of_birth date,
	birth_country varchar(60),
	email_address varchar(50),
	city_name varchar(60),
	zip_code varchar(10),
	country_name varchar(20),
	gmt_timezone_offset number(10,2),
	preferred_cust_flag boolean,
	registration_time timestamp_ltz(9)
);
truncate table customer_csv;
create file format customer_csv_ff
type = csv
field_delimiter = ','
skip_header = 1
-- record_delimiter = '\n' -- need to clarify
-- ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE | FALSE -- if set true then it doesn't give any error even if no.of columns in table is mismatched
-- NULL_IF = ('\\N', 'NULL', 'NUL', '') -- if any values in data like '\\N', 'NULL', 'NUL', '' are set to NULL
-- SKIP_BLANK_LINES = TRUE | FALSE -- it skips any blank line csv file
-- field_optionally_enclosed_by = '\042' (for double quotes) | '\047' (for single quotes) -- used if any field value is enclosed with single or double quotes
;

create stage internal           -- creating internal storage
file_format = customer_csv_ff;

show stages;
list @internal;

alter file format customer_csv_ff set field_optionally_enclosed_by = '\042', record_delimiter = '\n';

copy into customer_csv from @internal
on_error = 'continue' --| 'skip_file' | 'continue' | 'Abort_statement'(recommended)| 'skip_file_2'
force = True;
-- purge = true -- delete file from stage after loading
--VALIDATION_MODE = RETURN_ALL_ERRORS  -- to validate errors and it doesn't load data into tables
; 

remove @internal/customer_10k_good_data.csv.gz; -- to remove file from internal stage

select count(*) from customer_csv;