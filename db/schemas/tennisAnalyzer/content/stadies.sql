set feedback off
set define off
prompt Loading STADIES...
insert into STADIES (id, name, ord)
values ('Q1', '1st Round Qualifying', 1);
insert into STADIES (id, name, ord)
values ('Q2', '2nd Round Qualifying', 2);
insert into STADIES (id, name, ord)
values ('Q3', '3rd Round Qualifying', 3);
insert into STADIES (id, name, ord)
values ('F', 'Finals', 13);
insert into STADIES (id, name, ord)
values ('BR', 'Olympic Bronze', 12);
insert into STADIES (id, name, ord)
values ('QF', 'Quarter-Finals', 10);
insert into STADIES (id, name, ord)
values ('RR', 'Round Robin', 9);
insert into STADIES (id, name, ord)
values ('R128', 'Round of 128', 4);
insert into STADIES (id, name, ord)
values ('R16', 'Round of 16', 7);
insert into STADIES (id, name, ord)
values ('R32', 'Round of 32', 6);
insert into STADIES (id, name, ord)
values ('R64', 'Round of 64', 5);
insert into STADIES (id, name, ord)
values ('SF', 'Semi-Finals', 11);
insert into STADIES (id, name, ord)
values ('3P', '3rd/4th Place Match', 8);
commit;
prompt 13 records loaded
set feedback on
set define on
prompt Done.
