create database snowflake_practice;
create schema streams_tasks_merge_practice;

create file format json_format
type = json;

create or replace stage json_stage
file_format = json_format;

CREATE or replace TABLE HEALTHCARE_JSON(
    id VARCHAR(50)
   ,AVERAGE_COVERED_CHARGES    VARCHAR(150)  
   ,AVERAGE_TOTAL_PAYMENTS    VARCHAR(150)  
   ,TOTAL_DISCHARGES    INTEGER
   ,BACHELORORHIGHER    FLOAT
   ,HSGRADORHIGHER    VARCHAR(150)   
   ,TOTALPAYMENTS    VARCHAR(128)  
   ,REIMBURSEMENT    VARCHAR(128)  
   ,TOTAL_COVERED_CHARGES    VARCHAR(128) 
   ,REFERRALREGION_PROVIDER_NAME    VARCHAR(256)  
   ,REIMBURSEMENTPERCENTAGE    VARCHAR(150)   
   ,DRG_DEFINITION    VARCHAR(256)  
   ,REFERRAL_REGION    VARCHAR(26)  
   ,INCOME_PER_CAPITA    VARCHAR(150)   
   ,MEDIAN_EARNINGSBACHELORS    VARCHAR(150)   
   ,MEDIAN_EARNINGS_GRADUATE    VARCHAR(150) 
   ,MEDIAN_EARNINGS_HS_GRAD    VARCHAR(150)   
   ,MEDIAN_EARNINGSLESS_THAN_HS    VARCHAR(150) 
   ,MEDIAN_FAMILY_INCOME    VARCHAR(150)   
   ,NUMBER_OF_RECORDS    VARCHAR(150)  
   ,POP_25_OVER    VARCHAR(150)  
   ,PROVIDER_CITY    VARCHAR(128)  
   ,PROVIDER_ID    VARCHAR(150)   
   ,PROVIDER_NAME    VARCHAR(256)  
   ,PROVIDER_STATE    VARCHAR(128)  
   ,PROVIDER_STREET_ADDRESS    VARCHAR(256)  
   ,PROVIDER_ZIP_CODE    VARCHAR(150) 
   ,filename    VARCHAR
   ,file_row_number VARCHAR
   ,load_timestamp timestamp default TO_TIMESTAMP_NTZ(current_timestamp)
);

create stream stream1 on table healthcare_json;

list @json_stage;

select current_time();
create or replace task root_task
warehouse = compute_wh
schedule ='1 minute'  as            -- 'using cron 0 20 20 10 4 UTC'
copy into HEALTHCARE_JSON from (select 
$1:"_id"::varchar,
$1:" Average Covered Charges "::varchar,
$1:" Average Total Payments "::varchar,
$1:" Total Discharges "::integer,
$1:"% Bachelor's or Higher"::float,
$1:"% HS Grad or Higher"::varchar,
$1:"Total payments"::varchar,
$1:"% Reimbursement"::varchar,
$1:"Total covered charges"::varchar,
$1:"Referral Region Provider Name"::varchar,
$1:"ReimbursementPercentage"::varchar,
$1:"DRG Definition"::varchar,
$1:"Referral Region"::varchar,
$1:"INCOME_PER_CAPITA"::varchar,
$1:"MEDIAN EARNINGS - BACHELORS"::varchar,
$1:"MEDIAN EARNINGS - GRADUATE"::varchar,
$1:"MEDIAN EARNINGS - HS GRAD"::varchar,
$1:"MEDIAN EARNINGS- LESS THAN HS"::varchar,
$1:"MEDIAN_FAMILY_INCOME"::varchar,
$1:"Number of Records"::varchar,
$1:"POP_25_OVER"::varchar,
$1:"Provider City"::varchar,
$1:"Provider Id"::varchar,
$1:"Provider Name"::varchar,
$1:"Provider State"::varchar,
$1:"Provider Street Address"::varchar,
$1:"Provider Zip Code"::varchar,
METADATA$FILENAME,
METADATA$FILE_ROW_NUMBER,
TO_TIMESTAMP_NTZ(current_timestamp)
from @json_stage);


create or replace task root_child_update_task
warehouse = compute_wh
after root_task as
update healthcare_json set average_covered_charges = 1;





alter task root_task suspend;
alter task root_task resume;

alter task root_child_update_task suspend;
alter task root_child_update_task resume;

show tasks;

select * from healthcare_json;
select * from stream1;
truncate table healthcare_json;