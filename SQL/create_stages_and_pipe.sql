merge into customer c
using customer_raw cr
    on c.customer_id = cr.customer_id
when matched and (
    c.first_name <> cr.first_name or
    c.last_name <> cr.last_name or
    c.email <> cr.email or
    c.street <> cr.street or
    c.city <> cr.city or
    c.state <> cr.state or
    c.country <> cr.country
) then update 
    set c.first_name = cr.first_name,
        c.last_name = cr.last_name,
        c.email = cr.email,
        c.street = cr.street,
        c.city = cr.city,
        c.state = cr.state,
        c.country = cr.country,
        c.update_timestamp = current_timestamp()
when not matched then insert (
    customer_id, first_name, last_name, email, street, city, state, country
)
values (
    cr.customer_id, cr.first_name, cr.last_name, cr.email, cr.street, cr.city, cr.state, cr.country
);

select * from customer;

TRUNCATE customer;

CREATE OR REPLACE PROCEDURE pdr_scd_demo()
returns string not null
language javascript
as
    $$
      var cmd = `
                 merge into customer c 
                 using customer_raw cr
                    on  c.customer_id = cr.customer_id
                 when matched and c.customer_id <> cr.customer_id or
                                  c.first_name  <> cr.first_name  or
                                  c.last_name   <> cr.last_name   or
                                  c.email       <> cr.email       or
                                  c.street      <> cr.street      or
                                  c.city        <> cr.city        or
                                  c.state       <> cr.state       or
                                  c.country     <> cr.country then update
                     set c.customer_id = cr.customer_id
                         ,c.first_name  = cr.first_name 
                         ,c.last_name   = cr.last_name  
                         ,c.email       = cr.email      
                         ,c.street      = cr.street     
                         ,c.city        = cr.city       
                         ,c.state       = cr.state      
                         ,c.country     = cr.country  
                         ,update_timestamp = current_timestamp()
                 when not matched then insert
                            (c.customer_id,c.first_name,c.last_name,c.email,c.street,c.city,c.state,c.country)
                     values (cr.customer_id,cr.first_name,cr.last_name,cr.email,cr.street,cr.city,cr.state,cr.country);
      `
      var cmd1 = "truncate table SCD_DEMO.SCD2.customer_raw;"
      var sql = snowflake.createStatement({sqlText: cmd});
      var sql1 = snowflake.createStatement({sqlText: cmd1});
      var result = sql.execute();
      var result1 = sql1.execute();
    return cmd+'\n'+cmd1;
    $$;
call pdr_scd_demo();

--set up TASKAMIN role
use role securityadmin;
create or replace role taskadmin;
-- Set the active role to ACCOUNTADMIN before granting the EXECUTE TASK privilege to TASKADMIN
use role accountadmin;
grant execute task on account to role taskadmin;

-- Set the active role to SECURITYADMIN to show that this role can grant a role to another role 
use role securityadmin;
grant role taskadmin to role sysadmin;

use database scd_demo;
use schema scd2;

USE ROLE ACCOUNTADMIN;  -- or SYSADMIN if that's what you use

--creating task
create or replace task tsk_scd_raw warehouse = COMPUTE_WH schedule = '1 minute'
ERROR_ON_NONDETERMINISTIC_MERGE=FALSE
as
call pdr_scd_demo();

show tasks;

--unsuspend and doing resume
alter task tsk_scd_raw resume;

show tasks;

select timestampdiff(second, current_timestamp, scheduled_time) as next_run, scheduled_time, current_timestamp, name, state 
from table(information_schema.task_history()) where state = 'SCHEDULED' order by completed_time desc;

select * from customer;