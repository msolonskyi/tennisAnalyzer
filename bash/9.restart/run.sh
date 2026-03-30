#!/bin/bash

find /home/opc/projects/.tennis/csv  -type f -mtime +30 -delete

rm -f /home/opc/projects/.tennis/0.0.load_atp_all/go.run
rm -f /home/opc/projects/.tennis/0.0.load_tournaments/go.run
sudo shutdown -r now >> log.log
