create database if not exists scd_demo;

use database scd_demo;
create schema if not exists scd2;
use schema scd2;
show tables;

create or replace table customer(
    customer_id number,
    first_name varchar,
    last_name varchar,
    email varchar,
    street varchar,
    city varchar,
    state varchar,
    country varchar,
    update_timestamp timestamp_ntz default current_timestamp()
);

create or replace table customer_history(
    customer_id number,
    first_name varchar,
    last_name varchar,
    email varchar,
    street varchar,
    city varchar,
    state varchar,
    county varchar,
    start_time timestamp_ntz default current_timestamp(),
    update_timestamp timestamp_ntz default current_timestamp(),
    is_current boolean
);
drop table customer_history;
create or replace table customer_raw(
    customer_id number,
    first_name varchar,
    last_name varchar,
    email varchar,
    street varchar,
    city varchar,
    state varchar,
    country varchar
);

create or replace stream customer_table_changes on table customer;
