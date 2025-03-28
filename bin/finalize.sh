#!/bin/bash
#

source ./env.common


echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Finalizing ...
echo

rm -rf ${RTDRDATA}/__DATETIMESTAMP__

#
# Keep only the patient data archive files for the last ${ZIPKEEPDAYS} days
#

# Refresh datetimestamp for README.md to avoid deletion.
cp ${RTDRARXIV}/README.md ${RTDRARXIV}/README.bk
rm ${RTDRARXIV}/README.md && mv ${RTDRARXIV}/README.bk ${RTDRARXIV}/README.md

# Estimate the minimal zip file size and find the actual zip file size
NUMPT=`cat ${SQLOUTPATH}/_patient_list.uniq | wc -l`
ZIPSMIN=$((${NUMPT}*${PLAN_PCT}/100*${PLANSIZE}*${ZIP2_PCT}/100))
ZIPSIZE=`du -cm ${ZIPCOMMON}*.zip | grep total | awk '{print $1}'`

echo Estimated min ZIP file size: $ZIPSMIN
echo Actual  total ZIP file size: $ZIPSIZE

# If zip file size is reasonalble, delete the backup ${ZIPKEEPDAYS} days ago.
ZIPKEEPMINS=$((${ZIPKEEPDAYS}*24*60+6*60))  # add 6 hrs to avoid deleting only some files from one day
if [ "${ZIPSIZE}" -gt "${ZIPSMIN}" ]; then
    find ${RTDRARXIV} -mmin +${ZIPKEEPMINS} -delete 
    find $(dirname ${SQLOUTPATH}) -type d -mmin +${ZIPKEEPMINS} -prune -execdir rm -rf {} +
    echo Backup is reasonable. Cleanup Done!
else
    echo WARNING: possible backup issue!!
fi

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'` All Done!!!
echo
