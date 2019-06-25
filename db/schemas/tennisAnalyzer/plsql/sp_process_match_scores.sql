create or replace procedure sp_process_match_scores
is
  cv_module_name constant varchar2(200) := 'process match scores';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  -- adding new players
  -- winners
  insert into players(url, code, delta_hash, batch_id)
  select distinct s.winner_url as url, s.winner_code as code,
         ora_hash(null || '|' || null || '|' || s.winner_url || '|' || null || '|' || s.winner_code || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null) as delta_hash,
         pkg_log.gn_batch_id
  from stg_match_scores s
  where s.winner_code not in (select p.code from players p);
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (winners)', pn_qty => vn_qty);
  -- losers
  insert into players(url, code, delta_hash, batch_id)
  select distinct s.loser_url as url, s.loser_code as code,
         ora_hash(null || '|' || null || '|' || s.loser_url || '|' || null || '|' || s.loser_code || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null) as delta_hash,
         pkg_log.gn_batch_id
  from stg_match_scores s
  where s.loser_code not in (select p.code from players p);
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (losers)', pn_qty => vn_qty);
  --
  merge into match_scores d
  using(select *
        from (select t.id as tournament_id,
                     m.match_stats_url as stats_url,
                     s.id as stadie_id,
                     m.match_order,
                     w.id as winner_id,
                     l.id as loser_id,
                     m.winner_seed,
                     m.loser_seed,
                     m.match_score as match_score_raw,
                     m.winner_sets_won,
                     m.loser_sets_won,
                     m.winner_games_won,
                     m.loser_games_won,
                     m.winner_tiebreaks_won,
                     m.loser_tiebreaks_won,
                     m.match_ret,
                     row_number() over (partition by t.id, w.id, l.id, s.id order by m.match_order) rn,
                     ora_hash(t.id || '|' || m.match_stats_url || '|' || s.id || '|' || m.match_order || '|' || w.id || '|' || l.id || '|' || m.winner_seed || '|' || m.loser_seed || '|' || m.match_score || '|' || m.winner_sets_won || '|' || m.loser_sets_won || '|' || m.winner_games_won || '|' || m.loser_games_won || '|' || m.winner_tiebreaks_won || '|' || m.loser_tiebreaks_won || '|' || m.match_ret) as delta_hash
              from stg_match_scores m, tournaments t, stadies s,
                   players w, players l
              where m.tourney_year_id = t.year || '-' || t.code
                and upper(trim(m.tourney_round_name)) = upper(s.name(+))
                and m.winner_code = w.code
                and m.loser_code = l.code) i
        where rn = 1) s
  on (s.tournament_id || '-' || s.stadie_id || '-' || s.winner_id || '-' || s.loser_id = d.tournament_id || '-' || d.stadie_id || '-' || d.winner_id || '-' || d.loser_id)
  when not matched then
    insert (d.tournament_id, d.batch_id,          d.delta_hash, d.stats_url, d.stadie_id,d. match_order, d.winner_id, d.loser_id, d.winner_seed, d.loser_seed, d.match_score_raw, d.winner_sets_won, d.loser_sets_won, d.winner_games_won, d.loser_games_won, d.winner_tiebreaks_won, d.loser_tiebreaks_won, d.match_ret)
    values (s.tournament_id, pkg_log.gn_batch_id, s.delta_hash, s.stats_url, s.stadie_id, s.match_order, s.winner_id, s.loser_id, s.winner_seed, s.loser_seed, s.match_score_raw, s.winner_sets_won, s.loser_sets_won, s.winner_games_won, s.loser_games_won, s.winner_tiebreaks_won, s.loser_tiebreaks_won, s.match_ret)
  when matched then
    update set
      d.delta_hash           = s.delta_hash,
      d.batch_id             = pkg_log.gn_batch_id,
      d.match_order          = s.match_order,
      d.winner_seed          = s.winner_seed,
      d.loser_seed           = s.loser_seed,
      d.match_score_raw      = s.match_score_raw,
      d.winner_sets_won      = s.winner_sets_won,
      d.loser_sets_won       = s.loser_sets_won,
      d.winner_games_won     = s.winner_games_won,
      d.loser_games_won      = s.loser_games_won,
      d.winner_tiebreaks_won = s.winner_tiebreaks_won,
      d.loser_tiebreaks_won  = s.loser_tiebreaks_won,
      d.match_ret            = s.match_ret
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_text => 'rows processed', pn_qty => vn_qty);
  pkg_log.sp_finish_batch_successfully;
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
    pkg_log.sp_finish_batch_with_errors;
    raise;
end sp_process_match_scores;
/
