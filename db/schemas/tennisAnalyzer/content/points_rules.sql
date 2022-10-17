set feedback off
set define off
prompt Loading POINTS_RULES...
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('fu25', 'ITF Futures 25', 'fu25', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('fu15', 'ITF Futures 15', 'fu15', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('gsCup', 'Grand Slam Cup', 'gsCup', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('gs', 'Grand Slam', 'gs', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('1000-R128', 'ATP Masters 1000 R128', '1000', 'R128');
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('1000-R64', 'ATP Masters 1000 R64', '1000', 'R64');
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('atpFinals', 'ATP Finals', 'atpFinal', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('atp500-R64', 'ATP 500 Series R64', 'atp500', 'R64');
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('atp500-R32', 'ATP 500 Series R32', 'atp500', 'R32');
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('ch50', 'ATP Challenger 50', 'ch50', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('ch100', 'ATP Challenger 100', 'ch100', null);
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('atp250-R64', 'ATP 500 Series R64', 'atp250', 'R64');
insert into POINTS_RULES (id, name, series_category_id, first_stadie_id)
values ('atp250-R32', 'ATP 500 Series R32', 'atp250', 'R32');
commit;
prompt 13 records loaded
set feedback on
set define on
prompt Done.
