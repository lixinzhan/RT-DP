#!/bin/bash
#

source ./env.ehelper

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  Files for PowerScript Uploading ...
echo

#tstart=`date +%s`

tail -n +3 ${SQLOUTPATH}/DocFileLocation.csv | \
	awk -F, -v prfx="${FILE_SERVER//\\/\\\\}" '{print prfx $4}' > $SQLOUTPATH/$DOC_LIST_FILE

NEWIMAGEDIR1=$(echo $IMAGEDIR1 | sed -r 's/\\/\\\\/g' | sed -r 's/\$/\\\$/g')
NEWIMAGEDIR2=$(echo $IMAGEDIR2 | sed -r 's/\\/\\\\/g' | sed -r 's/\$/\\\$/g')
NEWIMAGEDIR3=$(echo $IMAGEDIR3 | sed -r 's/\\/\\\\/g' | sed -r 's/\$/\\\$/g')
NEWIMAGEDIR4=$(echo $IMAGEDIR4 | sed -r 's/\\/\\\\/g' | sed -r 's/\$/\\\$/g')
#echo $NEWIMAGEDIR1
#echo $NEWIMAGEDIR2
#echo $NEWIMAGEDIR3

tail -n +3 ${SQLOUTPATH}/ImgFileLocation.csv | \
	 sed -r "s/%%imagedir4/${NEWIMAGEDIR3}/gI" | \
	 sed -r "s/%%imagedir3/${NEWIMAGEDIR3}/gI" | \
	 sed -r "s/%%imagedir2/${NEWIMAGEDIR2}/gI" | \
	 sed -r "s/%%imagedir1/${NEWIMAGEDIR1}/gI" | \
	 awk -F, '{print $2}' > $SQLOUTPATH/$DCM_LIST_FILE

scp -P $EHLP_SSHPORT $SQLOUTPATH/$DOC_LIST_FILE $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE
scp -P $EHLP_SSHPORT $SQLOUTPATH/$DCM_LIST_FILE $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE
scp -P $EHLP_SSHPORT $RTDRPATH/bin/Copy-RTFiles.ps1 $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE

PSTRIGGER=$RTDRTMP/__PSTRIGGER__
touch $PSTRIGGER
scp -P $EHLP_SSHPORT $PSTRIGGER $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE
rm -rf $PSTRIGGER

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  Files for PowerScript Running Uploaded!
echo
