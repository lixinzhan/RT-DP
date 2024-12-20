#!/bin/bash
#

source ./env.common

rm -rf ${RTDRDATA}/__DATETIMESTAMP__
#rm -rf ${RTDRTMP}/*.zip

#
# Keep only the patient data archive files for the last ${ZIPKEEPDAYS} days
#
cp ${RTDRARXIV}/README.md ${RTDRARXIV}/README.bk
rm ${RTDRARXIV}/README.md && mv ${RTDRARXIV}/README.bk ${RTDRARXIV}/README.md
#cd ${RTDRARXIV} && ls -1tr | head -n -91 | xargs --no-run-if-empty rm -rf
if compgen -G "${RTDRARXIV}/${ZIPCOMMON}*.zip" > /dev/null 2>&1; then
    find ${RTDRARXIV} -mtime +${ZIPKEEPDAYS} -delete
fi

