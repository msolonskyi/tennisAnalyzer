set feedback off
set define off
prompt Loading SERIES...
insert into SERIES (id, name)
values ('ch', 'ATP Challenger Tour');
insert into SERIES (id, name)
values ('atp', 'ATP World Tour');
insert into SERIES (id, name)
values ('1000', 'ATP World Tour Masters 1000');
insert into SERIES (id, name)
values ('dc', 'Davis Cup');
insert into SERIES (id, name)
values ('gs', 'Grand Slame');
insert into SERIES (id, name)
values ('fu', 'ITF Futures');
insert into SERIES (id, name)
values ('og', 'Olympic Games');
commit;
prompt 7 records loaded
set feedback on
set define on
prompt Done.
