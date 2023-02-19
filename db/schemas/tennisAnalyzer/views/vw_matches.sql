create or replace view vw_matches as
select * from vw_atp_matches
union all
select * from vw_dc_matches
/
