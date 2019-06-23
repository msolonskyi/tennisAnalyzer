set feedback off
set define off
prompt Loading STADIES...
insert into STADIES (id, name, pos, short_name)
values (10, '1st Round Qualifying', 1, 'Q1');
insert into STADIES (id, name, pos, short_name)
values (9, '2nd Round Qualifying', 2, 'Q2');
insert into STADIES (id, name, pos, short_name)
values (8, '3rd Round Qualifying', 3, 'Q3');
insert into STADIES (id, name, pos, short_name)
values (1, 'Finals', 13, 'F');
insert into STADIES (id, name, pos, short_name)
values (12, 'Olympic Bronze', 12, 'BR');
insert into STADIES (id, name, pos, short_name)
values (3, 'Quarter-Finals', 10, 'QF');
insert into STADIES (id, name, pos, short_name)
values (11, 'Round Robin', 9, 'RR');
insert into STADIES (id, name, pos, short_name)
values (7, 'Round of 128', 4, 'R128');
insert into STADIES (id, name, pos, short_name)
values (4, 'Round of 16', 7, 'R16');
insert into STADIES (id, name, pos, short_name)
values (5, 'Round of 32', 6, 'R32');
insert into STADIES (id, name, pos, short_name)
values (6, 'Round of 64', 5, 'R64');
insert into STADIES (id, name, pos, short_name)
values (2, 'Semi-Finals', 11, 'SF');
insert into STADIES (id, name, pos, short_name)
values (13, '3rd/4th Place Match', 8, 'P3');
commit;
prompt 13 records loaded
set feedback on
set define on
prompt Done.
