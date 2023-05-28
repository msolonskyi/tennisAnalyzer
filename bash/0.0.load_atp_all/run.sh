#!/bin/bash

cd ..
python ./load_atp_tournaments.py 
python ./load_atp_matches.py
python ./load_atp_players.py
python ./load_atp_stats.py
