-- Create the user 
create user TENNISANALYZER
  default tablespace DATA
  temporary tablespace TEMP
  profile DEFAULT;
-- Grant/Revoke role privileges 
grant connect to TENNISANALYZER;
grant graph_developer to TENNISANALYZER;
grant resource to TENNISANALYZER;
grant select_catalog_role to TENNISANALYZER;
-- Grant/Revoke system privileges 
grant alter session to TENNISANALYZER;
grant create analytic view to TENNISANALYZER;
grant create database link to TENNISANALYZER;
grant create materialized view to TENNISANALYZER;
grant create procedure to TENNISANALYZER;
grant create sequence to TENNISANALYZER;
grant create session to TENNISANALYZER;
grant create table to TENNISANALYZER;
grant create trigger to TENNISANALYZER;
grant create type to TENNISANALYZER;
grant create view to TENNISANALYZER;
grant debug connect session to TENNISANALYZER;
grant restricted session to TENNISANALYZER;
grant select any dictionary to TENNISANALYZER;
grant select any table to TENNISANALYZER;
grant unlimited tablespace to TENNISANALYZER;
