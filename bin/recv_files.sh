#!/bin/bash
#

source ./env.ehelper

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Receiving Files from EHELPER ...
echo

#tstart=`date +%s`

rm -rf $RTDRPATH/tmp/*.zip
echo Retrieving documents.zip ...
scp -P $EHLP_SSHPORT $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE/documents.zip $RTDRPATH/tmp
echo Retrieving dicom.zip ...
scp -P $EHLP_SSHPORT $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE/dicom.zip $RTDRPATH/tmp
echo Retrieving PowerScript running logs if there is any ...
scp -P $EHLP_SSHPORT $EHLP_USER@$EHLP_SERVER:$EHLP_CACHE/*.log $RTDRPATH/Data/log


chmod -R 744 $RTDRPATH/Data/EHLPDOC${DAY3TAG} 
chmod -R 744 $RTDRPATH/Data/EHLPDCM${DAY3TAG} 
rm -rf $RTDRPATH/Data/EHLPDOC${DAY3TAG} 
rm -rf $RTDRPATH/Data/EHLPDCM${DAY3TAG}

echo $DATESTAMP $TIMESTAMP > $RTDRTMP/unzip.log
echo Unzipping documents.zip ...
unzip -o $RTDRPATH/tmp/documents.zip -d $RTDRPATH/Data/EHLPDOC${DAY3TAG}/ >> $RTDRTMP/unzip.log 2>&1
echo Unzipping dicom.zip ...
unzip -o $RTDRPATH/tmp/dicom.zip     -d $RTDRPATH/Data/EHLPDCM${DAY3TAG}/ >> $RTDRTMP/unzip.log 2>&1

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Files from EHELPER Received and Unzipped!
echo
