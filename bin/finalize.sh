#!/bin/bash
#

source ./env.common

rm -rf ${RTDRDATA}/__DATETIMESTAMP__
#rm -rf ${RTDRTMP}/*.zip

#
# Keep only the last 15 patient data archive files
#
mv ${RTDRARXIV}/README.md ${RTDRTMP}/README.arx.backup
cd ${RTDRARXIV} && ls -1tr | head -n -91 | xargs --no-run-if-empty rm -rf
mv ${RTDRTMP}/README.arx.backup ${RTDRARXIV}/README.md

