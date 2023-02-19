create or replace procedure sp_enrich_atp_matches_recent
is
  v_match_ids t_list_of_varchar := t_list_of_varchar();
  vc_duration constant number(4) := 22;
begin
  for rec in (select m.id
              from atp_matches m, atp_tournaments t
              where m.tournament_id = t.id
                and t.start_dtm > sysdate - vc_duration)
  loop
      v_match_ids.extend;
      v_match_ids(v_match_ids.count) := rec.id;
  end loop;
  --
  sp_enrich_atp_matches(v_match_ids);
  --
end sp_enrich_atp_matches_recent;
/
