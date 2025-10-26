#!/bin/bash

cd /home/opc/projects/.tennis
python ./load_atp_tournaments.py
python ./load_atp_draws.py qual_draw
python ./load_atp_draws.py main_draw
