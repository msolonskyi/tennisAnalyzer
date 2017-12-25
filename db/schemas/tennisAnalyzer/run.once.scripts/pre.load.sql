update stg_tournaments
set tourney_id = 6120,
    tourney_url_suffix = '/en/scores/archive/nice/6120/1975/results'
where tourney_id is null
  and tourney_name = 'Nice'
/

update stg_tournaments
set tourney_id = 9037,
    tourney_url_suffix = '/en/scores/archive/tokyo/9037/1975/results'
where tourney_id is null
  and tourney_name = 'Tokyo WCT'
/
