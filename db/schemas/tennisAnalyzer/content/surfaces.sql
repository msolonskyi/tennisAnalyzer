set feedback off
set define off
prompt Loading SURFACES...
insert into SURFACES (surface)
values ('Carpet');
insert into SURFACES (surface)
values ('Clay');
insert into SURFACES (surface)
values ('Grass');
insert into SURFACES (surface)
values ('Hard');
commit;
prompt 4 records loaded
set feedback on
set define on
prompt Done.
