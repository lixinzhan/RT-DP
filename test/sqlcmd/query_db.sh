#!/bin/bash -x
#

source ./env.sql

###############################################
# Queries
###############################################

sql_query "${RTEMRPATH}/SQLScripts/TreatmentScheduledNext7Days.sql"

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  DB Queries All Done!
