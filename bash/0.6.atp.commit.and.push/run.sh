#!/bin/bash

cd ..
python ./store_data_in_csv_atp.py
cd /home/opc/projects/ManTennisData/atp
DATE="`date +%Y-%m-%d`"
git commit -a -m"atp update $DATE"
git push
