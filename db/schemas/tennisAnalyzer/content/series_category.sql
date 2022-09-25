set feedback off
set define off
prompt Loading SERIES_CATEGORY...
insert into SERIES_CATEGORY (id, name, series_id)
values ('laverCup', 'Laver Cup', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('atpFinal', 'ATP Finals', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('atpCup', 'ATP Cup', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('nextGen', 'Next Gen ATP Finals', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('chFinal', 'Challenger Tour Finals', 'ch');
insert into SERIES_CATEGORY (id, name, series_id)
values ('gs', 'Grand Slam', 'gs');
insert into SERIES_CATEGORY (id, name, series_id)
values ('1000', 'Masters 1000', '1000');
insert into SERIES_CATEGORY (id, name, series_id)
values ('atp250', 'ATP Tour 250', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('atp500', 'ATP Tour 500', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('dc', 'Davis Cup', 'dc');
insert into SERIES_CATEGORY (id, name, series_id)
values ('og', 'Olympic Games', 'og');
insert into SERIES_CATEGORY (id, name, series_id)
values ('fu15', 'Futures 15', 'fu');
insert into SERIES_CATEGORY (id, name, series_id)
values ('fu25', 'Futures 25', 'fu');
insert into SERIES_CATEGORY (id, name, series_id)
values ('ch100', 'ATP Challenger 100', 'ch');
insert into SERIES_CATEGORY (id, name, series_id)
values ('ch50', 'ATP Challenger 50', 'ch');
insert into SERIES_CATEGORY (id, name, series_id)
values ('teamCup', 'World Team Cup', 'atp');
insert into SERIES_CATEGORY (id, name, series_id)
values ('gsCup', 'Grand Slam Cup', 'gs');
commit;
prompt 17 records loaded
set feedback on
set define on
prompt Done.
