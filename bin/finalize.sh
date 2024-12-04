#!/bin/bash
#

source ./env.common

rm -rf ${RTDRDATA}/__DATETIMESTAMP__
#rm -rf ${RTDRTMP}/*.zip

#
# Keep only the patient data archive files for the last ${ZIPKEEPDAYX} days
#
mv ${RTDRARXIV}/README.md ${RTDRTMP}/README.arx.backup
#cd ${RTDRARXIV} && ls -1tr | head -n -91 | xargs --no-run-if-empty rm -rf
if compgen -G "${RTDRARXIV}/${ZIPCOMMON}*.zip" > /dev/null 2>&1; then
    find ${RTDRARXIV} -mtime +${ZIPKEEPDAYS} -delete
fi
mv ${RTDRTMP}/README.arx.backup ${RTDRARXIV}/README.md

