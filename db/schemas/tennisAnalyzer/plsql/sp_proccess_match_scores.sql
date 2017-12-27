create or replace procedure sp_proccess_match_scores
is
  cv_module_name constant varchar2(200) := 'process match scores';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  -- adding new players
  -- winners
  insert into players(first_name, last_name, url, slug, code)
  select distinct substr(m.winner_name, 1, instr(m.winner_name, ' ', -1) - 1) as first_name,
         substr(m.winner_name, instr(m.winner_name, ' ', -1) + 1) as last_name,
         'http://www.atpworldtour.com/en/players/' || m.winner_slug || '/' || m.winner_player_id || '/overview' as url, m.winner_slug as slug, m.winner_player_id as code
  from stg_match_scores m
  where m.winner_player_id not in (select p.code from players p);
  -- losers
  insert into players(first_name, last_name, url, slug, code)
  select distinct substr(m.loser_name, 1, instr(m.loser_name, ' ', -1) - 1) as first_name,
         substr(m.loser_name, instr(m.loser_name, ' ', -1) + 1) as last_name,
         'http://www.atpworldtour.com/en/players/' || m.loser_slug || '/' || m.loser_player_id || '/overview' as url, m.loser_slug as slug, m.loser_player_id as code
  from stg_match_scores m
  where m.loser_player_id not in (select p.code from players p);
  --
  merge into match_scores d
  using(select t.id as tournaments_id,
               m.match_stats_url_suffix as stats_url,
               s.id as stadie_id,
               m.match_order,
               w.id as winner_id,
               l.id as loser_id,
               m.winner_seed,
               m.loser_seed,
               m.match_score_tiebreaks as match_score_raw,
               m.winner_sets_won,
               m.loser_sets_won,
               m.winner_games_won,
               m.loser_games_won,
               m.winner_tiebreaks_won,
               m.loser_tiebreaks_won
        from stg_match_scores m, tournaments t, stadies s,
             players w, players l
        where m.tourney_year_id = t.year || '-' || t.code
          and upper(trim(m.tourney_round_name)) = upper(s.name(+))
          and m.winner_player_id = w.code
          and m.loser_player_id = l.code) s
  on (s.tournaments_id || '-' || s.winner_id || '-' || s.loser_id || '-' || s.stats_url = d.tournaments_id || '-' || d.winner_id || '-' || d.loser_id || '-' || d.stats_url)
  when not matched then
    insert (tournaments_id, stats_url, stadie_id, match_order, winner_id, loser_id, winner_seed, loser_seed, match_score_raw, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won)
    values (s.tournaments_id, s.stats_url, s.stadie_id, s.match_order, s.winner_id, s.loser_id, s.winner_seed, s.loser_seed, s.match_score_raw, s.winner_sets_won, s.loser_sets_won, s.winner_games_won, s.loser_games_won, s.winner_tiebreaks_won, s.loser_tiebreaks_won)
  when matched then
    update set
      match_order          = s.match_order,
      winner_seed          = s.winner_seed,
      loser_seed           = s.loser_seed,
      match_score_raw      = s.match_score_raw,
      winner_sets_won      = s.winner_sets_won,
      loser_sets_won       = s.loser_sets_won,
      winner_games_won     = s.winner_games_won,
      loser_games_won      = s.loser_games_won,
      winner_tiebreaks_won = s.winner_tiebreaks_won,
      loser_tiebreaks_won  = s.loser_tiebreaks_won
    where nvl(d.match_order, pkg_utils.c_null_number_substitution)          != coalesce(s.match_order, pkg_utils.c_null_number_substitution) or
          nvl(d.winner_seed, pkg_utils.c_null_varchar_substitution)         != coalesce(s.winner_seed, pkg_utils.c_null_varchar_substitution) or
          nvl(d.loser_seed, pkg_utils.c_null_varchar_substitution)          != coalesce(s.loser_seed, pkg_utils.c_null_varchar_substitution) or
          nvl(d.match_score_raw, pkg_utils.c_null_varchar_substitution)     != coalesce(s.match_score_raw, pkg_utils.c_null_varchar_substitution) or
          nvl(d.winner_sets_won, pkg_utils.c_null_number_substitution)      != coalesce(s.winner_sets_won, pkg_utils.c_null_number_substitution) or
          nvl(d.loser_sets_won, pkg_utils.c_null_number_substitution)       != coalesce(s.loser_sets_won, pkg_utils.c_null_number_substitution) or
          nvl(d.winner_games_won, pkg_utils.c_null_number_substitution)     != coalesce(s.winner_games_won, pkg_utils.c_null_number_substitution) or
          nvl(d.loser_games_won, pkg_utils.c_null_number_substitution)      != coalesce(s.loser_games_won, pkg_utils.c_null_number_substitution) or
          nvl(d.winner_tiebreaks_won, pkg_utils.c_null_number_substitution) != coalesce(s.winner_tiebreaks_won, pkg_utils.c_null_number_substitution) or
          nvl(d.loser_tiebreaks_won, pkg_utils.c_null_number_substitution)  != coalesce(s.loser_tiebreaks_won, pkg_utils.c_null_number_substitution);
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_match_scores;
/
