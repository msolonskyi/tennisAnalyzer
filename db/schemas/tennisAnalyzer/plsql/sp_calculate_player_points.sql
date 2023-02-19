create or replace procedure sp_calculate_player_points
is
  cv_module_name constant varchar2(200) := 'calculate player points';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into player_points d
  using(select tournament_id, player_code, points,
               sf_player_points_delta_hash(
                 pv_tournament_id => tournament_id,
                 pv_player_code => player_code,
                 pn_points => points) as delta_hash
        from (select tournament_id, player_code, sum(points) as points
              from (-- winners
                    select m.tournament_id, m.winner_code as player_code, r.points
                      from points_rulebook r, vw_atp_matches m
                      where m.tournament_points_rule_id = r.points_rule_id
                        and m.stadie_id = r.stadie_id
                        and m.stadie_id = 'F'
                        and m.stadie_draw = 'M'
                        and r.result = 'W'
                      union all
                      -- main
                      select m.tournament_id, m.loser_code as player_code, r.points
                      from points_rulebook r, vw_atp_matches m
                      where m.tournament_points_rule_id = r.points_rule_id
                        and m.stadie_id = r.stadie_id
                        and m.stadie_draw = 'M'
                        and r.result = 'L'
                      union all
                      -- qualification Grand Slams
                      select m.tournament_id, m.winner_code as player_code, r.points
                      from points_rulebook r, vw_atp_matches m
                      where m.tournament_points_rule_id = r.points_rule_id
                        and m.stadie_id = r.stadie_id
                        and m.stadie_draw = 'Q'
                        and r.result = 'W'
                        and m.series_category_id = 'gs'
                      union all
                      select m.tournament_id, m.loser_code as player_code, r.points
                      from points_rulebook r, vw_atp_matches m
                      where m.tournament_points_rule_id = r.points_rule_id
                        and m.stadie_id = r.stadie_id
                        and m.stadie_draw = 'Q'
                        and r.result = 'L'
                        and m.series_category_id = 'gs'
                      union all
                      -- qualification winners
                      select m.tournament_id, m.winner_code as player_code, r.points
                      from (select m.tournament_id, max(m.stadie_ord) as stadie_ord
                            from vw_atp_matches m
                            where m.stadie_draw = 'Q'
                             and m.series_category_id != 'dc'
                            group by m.tournament_id) ii,
                           stadies s,
                           vw_atp_matches m,
                           points_rulebook r
                      where s.ord = ii.stadie_ord
                        and ii.tournament_id = m.tournament_id
                        and m.stadie_id = s.id
                        and m.tournament_points_rule_id = r.points_rule_id
                        and r.stadie_id = 'Q'
                        and r.result = 'W'
                        and m.stadie_id != 'Q1'
                      union all
                      -- qualification losers
                      select m.tournament_id, m.loser_code as player_code, r.points
                      from (select m.tournament_id, max(m.stadie_ord) as stadie_ord
                            from vw_atp_matches m
                            where m.stadie_draw = 'Q'
                             and m.series_category_id != 'dc'
                            group by m.tournament_id) ii,
                           stadies s,
                           vw_atp_matches m,
                           points_rulebook r
                      where s.ord = ii.stadie_ord
                        and ii.tournament_id = m.tournament_id
                        and m.stadie_id = s.id
                        and m.tournament_points_rule_id = r.points_rule_id
                        and r.stadie_id = 'Q'
                        and r.result = 'L'
                        and m.stadie_id != 'Q1'
                      union all
                      -- ATP Finals RR
                      select m.tournament_id, m.winner_code as player_code, r.points
                      from points_rulebook r, vw_atp_matches m
                      where m.tournament_points_rule_id = r.points_rule_id
                        and m.stadie_id = r.stadie_id
                        and m.stadie_id = 'RR'
                        and m.stadie_draw = 'M'
                        and r.result = 'W'
                      )
              group by tournament_id, player_code
              ) i
        ) s
  on (s.tournament_id = d.tournament_id and s.player_code = d.player_code)
  when not matched then
    insert (d.tournament_id, d.delta_hash, d.batch_id,          d.player_code, d.points)
    values (s.tournament_id, s.delta_hash, pkg_log.gn_batch_id, s.player_code, s.points)
  when matched then
    update set
      d.delta_hash  = s.delta_hash,
      d.batch_id    = pkg_log.gn_batch_id,
      d.points      = s.points
    where d.delta_hash != s.delta_hash;
  --
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
end sp_calculate_player_points;
/
