#!/bin/bash

cd /opt/zebrunner/mcloud-redroid/

if [[ -f backup/settings.env ]] && [[ -f .env ]]; then
  ./zebrunner.sh restart
else
  ./zebrunner.sh start < backup/setup.txt
fi
