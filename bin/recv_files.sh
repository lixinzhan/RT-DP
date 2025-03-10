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


EHLPDOC=${RTDRPATH}/Data/EHLPDOC #${DAY3TAG}
EHLPDCM=${RTDRPATH}/Data/EHLPDCM #${DAY3TAG}
chmod -R 744 ${EHLPDOC}* ${EHLPDCM}*
rm -rf ${EHLPDOC}.OLD2 ${EHLPDCM}.OLD2
if [ -d ${EHLPDOC}.OLD ]; then
	mv ${EHLPDOC}.OLD ${EHLPDOC}.OLD2
fi
if [ -d ${EHLPDCM}.OLD ]; then
	mv ${EHLPDCM}.OLD ${EHLPDCM}.OLD2
fi
if [ -d ${EHLPDOC} ]; then
    #chmod -R 744 ${EHLPDOC}
    #rm -rf ${EHLPDOC} 
    mv ${EHLPDOC} ${EHLPDOC}.OLD
fi
if [ -d ${EHLPDCM} ]; then
    #chmod -R 744 ${EHLPDCM}
    #rm -rf ${EHLPDCM}
    mv ${EHLPDCM} ${EHLPDCM}.OLD
fi

echo $DATESTAMP $TIMESTAMP > $RTDRTMP/unzip.log
echo Unzipping documents.zip ...
unzip -o $RTDRPATH/tmp/documents.zip -d ${EHLPDOC}/ >> $RTDRTMP/unzip.log 2>&1
touch ${EHLPDOC}/__RTDR_${DATESTAMP}${TIMESTAMP:0:4}__
echo Unzipping dicom.zip ...
unzip -o $RTDRPATH/tmp/dicom.zip     -d ${EHLPDCM}/ >> $RTDRTMP/unzip.log 2>&1
touch ${EHLPDCM}/__RTDR_${DATESTAMP}${TIMESTAMP:0:4}__

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Files from EHELPER Received and Unzipped!
echo
