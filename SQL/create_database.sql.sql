//creating external stage (create my own bucket)
CREATE OR REPLACE STAGE SCD_DEMO.SCD2.customer_ext_stage
url='s3://snowflake-db-tutorial-anish-kumar-thakur/stream_data'
credentials=(aws_key_id='***********',aws_secret_key='***************');

CREATE OR REPLACE FILE FORMAT SCD_DEMO.SCD2.CSV
TYPE = 'CSV'
FIELD_DELIMITER=","
SKIP_HEADER=1;

SHOW STAGES;
LIST @customer_ext_stage;

CREATE OR REPLACE PIPE customer_s3_pipe
    auto_ingest = true
    as
    COPY INTO customer_raw
    from @customer_ext_stage
    file_format = csv;

    show pipes;
    select SYSTEM$PIPE_STATUS('customer_s3_pipe');
    select * from customer_raw;
    
    TRUNCATE customer_raw;
