#!/bin/bash

cd /opt/zebrunner/mcloud-redroid/

if [[ -f backup/settings.env ]] && [[ -f .env ]]; then
  ./zebrunner.sh start
else
  ./zebrunner.sh start < backup/setup.txt
fi
