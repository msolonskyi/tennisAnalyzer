update stg_players
set flag_code = 'SGP'
where flag_code = 'SIN'
/

update stg_players
set flag_code = 'LBN'
where flag_code = 'LIB'
/

update stg_tournaments
   set tourney_fin_commit = '$4200000'
where tourney_url_suffix = '/en/scores/archive/munich/604/1999/results'
/

delete stg_tournaments
where tourney_url_suffix in ('/en/scores/archive/atp-doubles-challenge-cup/602/1999/results', '/en/scores/archive/atp-doubles-challenge-cup/602/2001/results', '/en/scores/archive/atp-doubles-challenge-cup/602/2000/results')
/

update stg_tournaments
set tourney_id = 6120,
    tourney_url_suffix = '/en/scores/archive/nice/6120/' || tourney_year || '/results',
    tourney_slug = 'nice',
    tourney_year_id = '6120-' || tourney_year
where tourney_id is null
  and tourney_name = 'Nice'
/

update stg_tournaments
set tourney_id = 9037,
    tourney_url_suffix = '/en/scores/archive/tokyo/9037/1975/results'
where tourney_id is null
  and tourney_name = 'Tokyo WCT'
/

update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/7308/MS003/match-stats' where match_stats_url_suffix = '/en/scores/2007/7308/MS002/match-stats' and match_id = '2007-7308-g621-d683';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/7308/MS005/match-stats' where match_stats_url_suffix = '/en/scores/2007/7308/MS004/match-stats' and match_id = '2007-7308-g621-g628';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/7308/MS006/match-stats' where match_stats_url_suffix = '/en/scores/2007/7308/MS004/match-stats' and match_id = '2007-7308-d683-k403';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/7308/MS007/match-stats' where match_stats_url_suffix = '/en/scores/2007/7308/MS004/match-stats' and match_id = '2007-7308-j194-s544';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/506/MS003/match-stats' where match_stats_url_suffix = '/en/scores/2007/506/MS002/match-stats' and match_id = '2007-506-d330-h502';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/506/MS005/match-stats' where match_stats_url_suffix = '/en/scores/2007/506/MS004/match-stats' and match_id = '2007-506-d330-m824';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/506/MS006/match-stats' where match_stats_url_suffix = '/en/scores/2007/506/MS004/match-stats' and match_id = '2007-506-h502-d469';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/506/MS007/match-stats' where match_stats_url_suffix = '/en/scores/2007/506/MS004/match-stats' and match_id = '2007-506-ma21-h390';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/499/MS003/match-stats' where match_stats_url_suffix = '/en/scores/2007/499/MS002/match-stats' and match_id = '2007-499-m680-s544';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/499/MS005/match-stats' where match_stats_url_suffix = '/en/scores/2007/499/MS004/match-stats' and match_id = '2007-499-s544-h355';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/499/MS006/match-stats' where match_stats_url_suffix = '/en/scores/2007/499/MS004/match-stats' and match_id = '2007-499-m680-g476';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/499/MS007/match-stats' where match_stats_url_suffix = '/en/scores/2007/499/MS004/match-stats' and match_id = '2007-499-b896-s480';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/433/MS003/match-stats' where match_stats_url_suffix = '/en/scores/2007/433/MS002/match-stats' and match_id = '2007-433-m762-k760';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/433/MS005/match-stats' where match_stats_url_suffix = '/en/scores/2007/433/MS004/match-stats' and match_id = '2007-433-s741-v306';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/433/MS006/match-stats' where match_stats_url_suffix = '/en/scores/2007/433/MS004/match-stats' and match_id = '2007-433-m762-h442';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/433/MS007/match-stats' where match_stats_url_suffix = '/en/scores/2007/433/MS004/match-stats' and match_id = '2007-433-k760-q927';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/505/MS003/match-stats' where match_stats_url_suffix = '/en/scores/2007/505/MS002/match-stats' and match_id = '2007-505-h390-v258';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/505/MS005/match-stats' where match_stats_url_suffix = '/en/scores/2007/505/MS004/match-stats' and match_id = '2007-505-m655-r388';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/505/MS006/match-stats' where match_stats_url_suffix = '/en/scores/2007/505/MS004/match-stats' and match_id = '2007-505-h390-a511';
update stg_match_scores set match_stats_url_suffix = '/en/scores/2007/505/MS007/match-stats' where match_stats_url_suffix = '/en/scores/2007/505/MS004/match-stats' and match_id = '2007-505-v258-b884';


update stg_match_scores c
set c.match_stats_url_suffix = (select s.match_stats_url_suffix
                                from stg_match_stats s
                                where c.match_id = s.match_id)
where c.tourney_year_id = '2017-560'
/
