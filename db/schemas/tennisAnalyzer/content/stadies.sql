set feedback off
set define off
prompt Loading STADIES...
insert into STADIES (id, name, ord, draw)
values ('Q1', '1st Round Qualifying', 1, 'Q');
insert into STADIES (id, name, ord, draw)
values ('Q2', '2nd Round Qualifying', 2, 'Q');
insert into STADIES (id, name, ord, draw)
values ('Q3', '3rd Round Qualifying', 3, 'Q');
insert into STADIES (id, name, ord, draw)
values ('F', 'Finals', 13, 'M');
insert into STADIES (id, name, ord, draw)
values ('BR', 'Olympic Bronze', 12, 'M');
insert into STADIES (id, name, ord, draw)
values ('QF', 'Quarter-Finals', 10, 'M');
insert into STADIES (id, name, ord, draw)
values ('RR', 'Round Robin', 9, 'M');
insert into STADIES (id, name, ord, draw)
values ('R128', 'Round of 128', 4, 'M');
insert into STADIES (id, name, ord, draw)
values ('R16', 'Round of 16', 7, 'M');
insert into STADIES (id, name, ord, draw)
values ('R32', 'Round of 32', 6, 'M');
insert into STADIES (id, name, ord, draw)
values ('R64', 'Round of 64', 5, 'M');
insert into STADIES (id, name, ord, draw)
values ('SF', 'Semi-Finals', 11, 'M');
insert into STADIES (id, name, ord, draw)
values ('3P', '3rd/4th Place Match', 8, 'M');
commit;
prompt 13 records loaded
set feedback on
set define on
prompt Done.
