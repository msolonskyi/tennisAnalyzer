create or replace procedure sp_process_scores_by_t(p_tournament_id tournaments.id%type)
is
  cv_module_name constant varchar2(200) := 'process scores';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_parameters => 'p_tournament_id: ' || p_tournament_id);
  --
  merge into scores d
  using(select v.*,
               ora_hash(match_score_id || '|' || match_id || '|' || tournament_id || '|' || tournament_name || '|' || tournament_code || '|' || tournament_url || '|' || tournament_city || '|' || tournament_year || '|' || tournament_week || '|' || tournament_sgl_draw_link || '|' || tournament_type_name || '|' || surface_name || '|' || tournament_start_dtm || '|' || tournament_sgl_draw_qty || '|' || tournament_dbl_draw_qty || '|' || series_name || '|' || series_code || '|' || tournament_prize_money || '|' || tournament_prize_currency || '|' || tournament_country_code || '|' || winner_id || '|' || winner_first_name || '|' || winner_last_name || '|' || winner_url || '|' || winner_code || '|' || winner_birth_date || '|' || winner_birthplace || '|' || winner_turned_pro || '|' || winner_weight || '|' || winner_height || '|' || winner_residence || '|' || winner_handedness || '|' || winner_backhand || '|' || winner_citizenship || '|' || loser_id || '|' || loser_first_name || '|' || loser_last_name || '|' || loser_url || '|' || loser_code || '|' || loser_birth_date || '|' || loser_birthplace || '|' || loser_turned_pro || '|' || loser_weight || '|' || loser_height || '|' || loser_residence || '|' || loser_handedness || '|' || loser_backhand || '|' || loser_citizenship || '|' || winner_seed || '|' || loser_seed || '|' || match_order || '|' || match_ret || '|' || match_score_raw || '|' || winner_sets_won || '|' || loser_sets_won || '|' || winner_games_won || '|' || loser_games_won || '|' || winner_tiebreaks_won || '|' || loser_tiebreaks_won || '|' || stats_url || '|' || stadie_name || '|' || stadie_pos || '|' || win_h2h_qty_52w || '|' || los_h2h_qty_52w || '|' || win_win_qty_52w || '|' || win_los_qty_52w || '|' || los_win_qty_52w || '|' || los_los_qty_52w || '|' || win_avg_tiebreaks_52w || '|' || los_avg_tiebreaks_52w || '|' || win_h2h_qty_52w_current || '|' || los_h2h_qty_52w_current || '|' || win_win_qty_52w_current || '|' || win_los_qty_52w_current || '|' || los_win_qty_52w_current || '|' || los_los_qty_52w_current || '|' || win_avg_tiebreaks_52w_current || '|' || los_avg_tiebreaks_52w_current || '|' || win_h2h_qty_all || '|' || los_h2h_qty_all || '|' || win_win_qty_all || '|' || win_los_qty_all || '|' || los_win_qty_all || '|' || los_los_qty_all || '|' || win_avg_tiebreaks_all || '|' || los_avg_tiebreaks_all || '|' || win_h2h_qty_all_current || '|' || los_h2h_qty_all_current || '|' || win_win_qty_all_current || '|' || win_los_qty_all_current || '|' || los_win_qty_all_current || '|' || los_los_qty_all_current || '|' || win_avg_tiebreaks_all_current || '|' || los_avg_tiebreaks_all_current) as delta_hash
        from (select m.id as match_score_id,
                     t.year || '-' || t.code || '-' || w.code || '-' || l.code || '-' || st.short_name as match_id,
                     t.id as tournament_id,
                     t.name as tournament_name,
                     t.code as tournament_code,
                     t.url as tournament_url,
                     t.city as tournament_city,
                     t.year as tournament_year,
                     t.week as tournament_week,
                     t.sgl_draw_link as tournament_sgl_draw_link,
                     tt.name as tournament_type_name,
                     su.name as surface_name,
                     t.start_dtm as tournament_start_dtm,
                     t.sgl_draw_qty as tournament_sgl_draw_qty,
                     t.dbl_draw_qty as tournament_dbl_draw_qty,
                     ts.name as series_name,
                     ts.code as series_code,
                     t.prize_money as tournament_prize_money,
                     t.prize_currency as tournament_prize_currency,
                     t.country_code as tournament_country_code,
                     w.id as winner_id,
                     w.first_name as winner_first_name,
                     w.last_name as winner_last_name,
                     w.url as winner_url,
                     w.code as winner_code,
                     w.birth_date as winner_birth_date,
                     w.birthplace as winner_birthplace,
                     w.turned_pro as winner_turned_pro,
                     w.weight as winner_weight,
                     w.height as winner_height,
                     w.residence as winner_residence,
                     w.handedness as winner_handedness,
                     w.backhand as winner_backhand,
                     w.citizenship as winner_citizenship,
                     l.id as loser_id,
                     l.first_name as loser_first_name,
                     l.last_name as loser_last_name,
                     l.url as loser_url,
                     l.code as loser_code,
                     l.birth_date as loser_birth_date,
                     l.birthplace as loser_birthplace,
                     l.turned_pro as loser_turned_pro,
                     l.weight as loser_weight,
                     l.height as loser_height,
                     l.residence as loser_residence,
                     l.handedness as loser_handedness,
                     l.backhand as loser_backhand,
                     l.citizenship as loser_citizenship,
                     m.winner_seed as winner_seed,
                     m.loser_seed as loser_seed,
                     m.match_order as match_order,
                     m.match_ret as match_ret,
                     m.match_score_raw as match_score_raw,
                     m.winner_sets_won as winner_sets_won,
                     m.loser_sets_won as loser_sets_won,
                     m.winner_games_won as winner_games_won,
                     m.loser_games_won as loser_games_won,
                     m.winner_tiebreaks_won as winner_tiebreaks_won,
                     m.loser_tiebreaks_won as loser_tiebreaks_won,
                     m.stats_url as stats_url,
                     st.name as stadie_name,
                     st.pos as stadie_pos,
                     -- 52 weeks
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.winner_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_52w,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.loser_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_52w,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_52w,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_52w,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_52w,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_52w,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_52w,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_52w,
                     -- current surface
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.winner_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_52w_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.loser_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_52w_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_52w_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_52w_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_52w_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_52w_current,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_52w_current,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_52w_current,
                     -- for all time
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.winner_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_all,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.loser_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_all,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_all,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_all,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.winner_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_all,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_all,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_all,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_all,
                     -- current surface
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.winner_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_all_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.loser_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_all_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_all_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.loser_id = m.winner_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_all_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.winner_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_all_current,
                     (select case
                               when m.match_ret is null then count(*)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and mi.loser_id = m.loser_id
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_all_current,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_all_current,
                     (select case
                               when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                               else null
                             end as qty
                      from match_scores mi, tournaments ti, stadies sti
                      where mi.tournament_id = ti.id
                        and mi.stadie_id = sti.id
                        and ti.surface_id = t.surface_id
                        and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
                        and mi.match_ret is null
                        and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_all_current
              from match_scores m, tournaments t, players w, players l, stadies st, tournament_series ts, tournament_types tt, surfaces su
              where m.winner_id = w.id
                and m.loser_id = l.id
                and m.tournament_id = t.id
                and t.id = p_tournament_id
                and m.stadie_id = st.id
                and t.surface_id = su.id
                and t.series_id = ts.id
                and t.type_id = tt.id) v) s
  on (s.match_score_id = d.match_score_id)
  when not matched then
      insert (d.match_score_id, d.batch_id,          d.delta_hash, d.match_id, d.tournament_id, d.tournament_name, d.tournament_code, d.tournament_url, d.tournament_city, d.tournament_year, d.tournament_week, d.tournament_sgl_draw_link, d.tournament_type_name, d.surface_name, d.tournament_start_dtm, d.tournament_sgl_draw_qty, d.tournament_dbl_draw_qty, d.series_name, d.series_code, d.tournament_prize_money, d.tournament_prize_currency, d.tournament_country_code, d.winner_id, d.winner_first_name, d.winner_last_name, d.winner_url, d.winner_code, d.winner_birth_date, d.winner_birthplace, d.winner_turned_pro, d.winner_weight, d.winner_height, d.winner_residence, d.winner_handedness, d.winner_backhand, d.winner_citizenship, d.loser_id, d.loser_first_name, d.loser_last_name, d.loser_url, d.loser_code, d.loser_birth_date, d.loser_birthplace, d.loser_turned_pro, d.loser_weight, d.loser_height, d.loser_residence, d.loser_handedness, d.loser_backhand, d.loser_citizenship, d.winner_seed, d.loser_seed, d.match_order, d.match_ret, d.match_score_raw, d.winner_sets_won, d.loser_sets_won, d.winner_games_won, d.loser_games_won, d.winner_tiebreaks_won, d.loser_tiebreaks_won, d.stats_url, d.stadie_name, d.stadie_pos, d.win_h2h_qty_52w, d.los_h2h_qty_52w, d.win_win_qty_52w, d.win_los_qty_52w, d.los_win_qty_52w, d.los_los_qty_52w, d.win_avg_tiebreaks_52w, d.los_avg_tiebreaks_52w, d.win_h2h_qty_52w_current, d.los_h2h_qty_52w_current, d.win_win_qty_52w_current, d.win_los_qty_52w_current, d.los_win_qty_52w_current, d.los_los_qty_52w_current, d.win_avg_tiebreaks_52w_current, d.los_avg_tiebreaks_52w_current, d.win_h2h_qty_all, d.los_h2h_qty_all, d.win_win_qty_all, d.win_los_qty_all, d.los_win_qty_all, d.los_los_qty_all, d.win_avg_tiebreaks_all, d.los_avg_tiebreaks_all, d.win_h2h_qty_all_current, d.los_h2h_qty_all_current, d.win_win_qty_all_current, d.win_los_qty_all_current, d.los_win_qty_all_current, d.los_los_qty_all_current, d.win_avg_tiebreaks_all_current, d.los_avg_tiebreaks_all_current)
      values (s.match_score_id, pkg_log.gn_batch_id, s.delta_hash, s.match_id, s.tournament_id, s.tournament_name, s.tournament_code, s.tournament_url, s.tournament_city, s.tournament_year, s.tournament_week, s.tournament_sgl_draw_link, s.tournament_type_name, s.surface_name, s.tournament_start_dtm, s.tournament_sgl_draw_qty, s.tournament_dbl_draw_qty, s.series_name, s.series_code, s.tournament_prize_money, s.tournament_prize_currency, s.tournament_country_code, s.winner_id, s.winner_first_name, s.winner_last_name, s.winner_url, s.winner_code, s.winner_birth_date, s.winner_birthplace, s.winner_turned_pro, s.winner_weight, s.winner_height, s.winner_residence, s.winner_handedness, s.winner_backhand, s.winner_citizenship, s.loser_id, s.loser_first_name, s.loser_last_name, s.loser_url, s.loser_code, s.loser_birth_date, s.loser_birthplace, s.loser_turned_pro, s.loser_weight, s.loser_height, s.loser_residence, s.loser_handedness, s.loser_backhand, s.loser_citizenship, s.winner_seed, s.loser_seed, s.match_order, s.match_ret, s.match_score_raw, s.winner_sets_won, s.loser_sets_won, s.winner_games_won, s.loser_games_won, s.winner_tiebreaks_won, s.loser_tiebreaks_won, s.stats_url, s.stadie_name, s.stadie_pos, s.win_h2h_qty_52w, s.los_h2h_qty_52w, s.win_win_qty_52w, s.win_los_qty_52w, s.los_win_qty_52w, s.los_los_qty_52w, s.win_avg_tiebreaks_52w, s.los_avg_tiebreaks_52w, s.win_h2h_qty_52w_current, s.los_h2h_qty_52w_current, s.win_win_qty_52w_current, s.win_los_qty_52w_current, s.los_win_qty_52w_current, s.los_los_qty_52w_current, s.win_avg_tiebreaks_52w_current, s.los_avg_tiebreaks_52w_current, s.win_h2h_qty_all, s.los_h2h_qty_all, s.win_win_qty_all, s.win_los_qty_all, s.los_win_qty_all, s.los_los_qty_all, s.win_avg_tiebreaks_all, s.los_avg_tiebreaks_all, s.win_h2h_qty_all_current, s.los_h2h_qty_all_current, s.win_win_qty_all_current, s.win_los_qty_all_current, s.los_win_qty_all_current, s.los_los_qty_all_current, s.win_avg_tiebreaks_all_current, s.los_avg_tiebreaks_all_current)
  when matched then
    update set
      d.delta_hash                    = s.delta_hash,
      d.batch_id                      = pkg_log.gn_batch_id,
      d.match_id                      = s.match_id,
      d.tournament_id                 = s.tournament_id,
      d.tournament_name               = s.tournament_name,
      d.tournament_code               = s.tournament_code,
      d.tournament_url                = s.tournament_url,
      d.tournament_city               = s.tournament_city,
      d.tournament_year               = s.tournament_year,
      d.tournament_week               = s.tournament_week,
      d.tournament_sgl_draw_link      = s.tournament_sgl_draw_link,
      d.tournament_type_name          = s.tournament_type_name,
      d.surface_name                  = s.surface_name,
      d.tournament_start_dtm          = s.tournament_start_dtm,
      d.tournament_sgl_draw_qty       = s.tournament_sgl_draw_qty,
      d.tournament_dbl_draw_qty       = s.tournament_dbl_draw_qty,
      d.series_name                   = s.series_name,
      d.series_code                   = s.series_code,
      d.tournament_prize_money        = s.tournament_prize_money,
      d.tournament_prize_currency     = s.tournament_prize_currency,
      d.tournament_country_code       = s.tournament_country_code,
      d.winner_id                     = s.winner_id,
      d.winner_first_name             = s.winner_first_name,
      d.winner_last_name              = s.winner_last_name,
      d.winner_url                    = s.winner_url,
      d.winner_code                   = s.winner_code,
      d.winner_birth_date             = s.winner_birth_date,
      d.winner_birthplace             = s.winner_birthplace,
      d.winner_turned_pro             = s.winner_turned_pro,
      d.winner_weight                 = s.winner_weight,
      d.winner_height                 = s.winner_height,
      d.winner_residence              = s.winner_residence,
      d.winner_handedness             = s.winner_handedness,
      d.winner_backhand               = s.winner_backhand,
      d.winner_citizenship            = s.winner_citizenship,
      d.loser_id                      = s.loser_id,
      d.loser_first_name              = s.loser_first_name,
      d.loser_last_name               = s.loser_last_name,
      d.loser_url                     = s.loser_url,
      d.loser_code                    = s.loser_code,
      d.loser_birth_date              = s.loser_birth_date,
      d.loser_birthplace              = s.loser_birthplace,
      d.loser_turned_pro              = s.loser_turned_pro,
      d.loser_weight                  = s.loser_weight,
      d.loser_height                  = s.loser_height,
      d.loser_residence               = s.loser_residence,
      d.loser_handedness              = s.loser_handedness,
      d.loser_backhand                = s.loser_backhand,
      d.loser_citizenship             = s.loser_citizenship,
      d.winner_seed                   = s.winner_seed,
      d.loser_seed                    = s.loser_seed,
      d.match_order                   = s.match_order,
      d.match_ret                     = s.match_ret,
      d.match_score_raw               = s.match_score_raw,
      d.winner_sets_won               = s.winner_sets_won,
      d.loser_sets_won                = s.loser_sets_won,
      d.winner_games_won              = s.winner_games_won,
      d.loser_games_won               = s.loser_games_won,
      d.winner_tiebreaks_won          = s.winner_tiebreaks_won,
      d.loser_tiebreaks_won           = s.loser_tiebreaks_won,
      d.stats_url                     = s.stats_url,
      d.stadie_name                   = s.stadie_name,
      d.stadie_pos                    = s.stadie_pos,
      d.win_h2h_qty_52w               = s.win_h2h_qty_52w,
      d.los_h2h_qty_52w               = s.los_h2h_qty_52w,
      d.win_win_qty_52w               = s.win_win_qty_52w,
      d.win_los_qty_52w               = s.win_los_qty_52w,
      d.los_win_qty_52w               = s.los_win_qty_52w,
      d.los_los_qty_52w               = s.los_los_qty_52w,
      d.win_avg_tiebreaks_52w         = s.win_avg_tiebreaks_52w,
      d.los_avg_tiebreaks_52w         = s.los_avg_tiebreaks_52w,
      d.win_h2h_qty_52w_current       = s.win_h2h_qty_52w_current,
      d.los_h2h_qty_52w_current       = s.los_h2h_qty_52w_current,
      d.win_win_qty_52w_current       = s.win_win_qty_52w_current,
      d.win_los_qty_52w_current       = s.win_los_qty_52w_current,
      d.los_win_qty_52w_current       = s.los_win_qty_52w_current,
      d.los_los_qty_52w_current       = s.los_los_qty_52w_current,
      d.win_avg_tiebreaks_52w_current = s.win_avg_tiebreaks_52w_current,
      d.los_avg_tiebreaks_52w_current = s.los_avg_tiebreaks_52w_current,
      d.win_h2h_qty_all               = s.win_h2h_qty_all,
      d.los_h2h_qty_all               = s.los_h2h_qty_all,
      d.win_win_qty_all               = s.win_win_qty_all,
      d.win_los_qty_all               = s.win_los_qty_all,
      d.los_win_qty_all               = s.los_win_qty_all,
      d.los_los_qty_all               = s.los_los_qty_all,
      d.win_avg_tiebreaks_all         = s.win_avg_tiebreaks_all,
      d.los_avg_tiebreaks_all         = s.los_avg_tiebreaks_all,
      d.win_h2h_qty_all_current       = s.win_h2h_qty_all_current,
      d.los_h2h_qty_all_current       = s.los_h2h_qty_all_current,
      d.win_win_qty_all_current       = s.win_win_qty_all_current,
      d.win_los_qty_all_current       = s.win_los_qty_all_current,
      d.los_win_qty_all_current       = s.los_win_qty_all_current,
      d.los_los_qty_all_current       = s.los_los_qty_all_current,
      d.win_avg_tiebreaks_all_current = s.win_avg_tiebreaks_all_current,
      d.los_avg_tiebreaks_all_current = s.los_avg_tiebreaks_all_current
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
end sp_process_scores_by_t;
/
