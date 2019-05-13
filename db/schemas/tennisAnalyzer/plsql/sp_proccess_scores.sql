create or replace procedure sp_proccess_scores
is
  cv_module_name constant varchar2(200) := 'process scores';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into scores d
  using(select m.id, 
                 ora_hash(t.id ||'|'|| t.name ||'|'|| t.code ||'|'|| t.url ||'|'|| t.city ||'|'|| t.country_code ||'|'|| t.year ||'|'|| t.week ||'|'|| t.type_id ||'|'|| tt.name ||'|'|| t.surface_id ||'|'|| su.name ||'|'|| t.start_dtm ||'|'|| t.series_id ||'|'|| ts.name ||'|'|| ts.code ||'|'|| t.prize_money ||'|'|| t.prize_currency) as delta_hash,
               t.id as tournament_id, 
               t.name as tournament_name, 
               t.code as tournament_code, 
               t.url as tournament_url, 
               t.city as tournament_city, 
               t.country_code as tournament_country_code, 
               t.year as tournament_year, 
               t.week as tournament_week, 
               t.type_id as tournament_type_id, 
               tt.name as tournament_type_name, 
               t.surface_id as tournament_surface_id, 
               su.name as tournament_surface_name, 
               t.start_dtm as tournament_start_dtm, 
               t.series_id as tournament_series_id, 
               ts.name as tournament_series_name, 
               ts.code as tournament_series_code, 
               t.prize_money as tournament_prize_money, 
               t.prize_currency as tournament_prize_currency
        from match_scores m, tournaments t, surfaces su, tournament_types tt, tournament_series ts--, stadies 
        where m.tournament_id = t.id
          and t.surface_id = su.id
          and t.type_id = tt.id
          and t.series_id = ts.id(+)) s
  on (s.id = d.id)
  when not matched then
      insert (d.id, d.delta_hash, d.tournament_id, d.tournament_name, d.tournament_code, d.tournament_url, d.tournament_city, d.tournament_country_code, d.tournament_year, d.tournament_week, d.tournament_type_id, d.tournament_type_name, d.tournament_surface_id, d.tournament_surface_name, d.tournament_start_dtm, d.tournament_series_id, d.tournament_series_name, d.tournament_series_code, d.tournament_prize_money, d.tournament_prize_currency)
      values (s.id, s.delta_hash, s.tournament_id, s.tournament_name, s.tournament_code, s.tournament_url, s.tournament_city, s.tournament_country_code, s.tournament_year, s.tournament_week, s.tournament_type_id, s.tournament_type_name, s.tournament_surface_id, s.tournament_surface_name, s.tournament_start_dtm, s.tournament_series_id, s.tournament_series_name, s.tournament_series_code, s.tournament_prize_money, s.tournament_prize_currency)
  when matched then
    update set
      d.delta_hash =                s.delta_hash,
      d.tournament_id =             s.tournament_id,
      d.tournament_name =           s.tournament_name,
      d.tournament_code =           s.tournament_code,
      d.tournament_url =            s.tournament_url,
      d.tournament_city =           s.tournament_city,
      d.tournament_country_code =   s.tournament_country_code,
      d.tournament_year =           s.tournament_year,
      d.tournament_week =           s.tournament_week,
      d.tournament_type_id =        s.tournament_type_id,
      d.tournament_type_name =      s.tournament_type_name,
      d.tournament_surface_id =     s.tournament_surface_id,
      d.tournament_surface_name =   s.tournament_surface_name,
      d.tournament_start_dtm =      s.tournament_start_dtm,
      d.tournament_series_id =      s.tournament_series_id,
      d.tournament_series_name =    s.tournament_series_name,
      d.tournament_series_code =    s.tournament_series_code,
      d.tournament_prize_money =    s.tournament_prize_money,
      d.tournament_prize_currency = s.tournament_prize_currency
    where d.delta_hash != s.delta_hash;
  --
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_scores;
/
