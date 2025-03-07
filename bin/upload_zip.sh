#!/bin/bash
#

source ./env.ehelper

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  Starting Archived Files Uploading ...
echo

#scp -P $EHLP_SSHPORT ${ZIPFILE%.*}.* $EHLP_USER@$EHLP_SERVER:$EHLP_DATA
scp -P $EHLP_SSHPORT ${ZIPCOMMON}* $EHLP_USER@$EHLP_SERVER:$EHLP_DATA
scp -P $EHLP_SSHPORT ${RTDRARXIV}/README.md $EHLP_USER@$EHLP_SERVER:$EHLP_DATA

#echo
#if [ $? -eq 0 ] 
#then
#	echo $(basename ${ZIPFILE}) upload to $EHLP_SERVER done successfully!
#else
#	echo $(basename ${ZIPFILE}) upload failed!
#fi
#echo

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  Archived Files Uploaded to EHELPER!
echo
