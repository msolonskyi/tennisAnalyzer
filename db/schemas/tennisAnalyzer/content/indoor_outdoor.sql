set feedback off
set define off
prompt Loading INDOOR_OUTDOOR...
insert into INDOOR_OUTDOOR (indoor_outdoor)
values ('Indoor');
insert into INDOOR_OUTDOOR (indoor_outdoor)
values ('Outdoor');
commit;
prompt 2 records loaded
set feedback on
set define on
prompt Done.
