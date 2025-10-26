#!/bin/bash

cd /home/opc/projects/.tennis
python ./load_atp_matches.py
python ./load_atp_players.py
python ./load_atp_stat_files.py
python ./load_atp_stats.py
