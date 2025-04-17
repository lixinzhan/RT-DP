#!/bin/bash
#

source ./env.ehelper
source ./env.email

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Sending email due to error occurred ...
echo

BKDATE=`echo $DATESTAMP | awk '{print substr($0,1,4)"-"substr($0,5,2)"-"substr($0,7,2)}'`
BKTIME=`echo $TIMESTAMP | awk '{print substr($0,1,2)":"substr($0,3,2)}'`

echo ">>>>>> $(hostname)  ${BKDATE} ${BKTIME} <<<<<<" > ${RTDRTMP}/email_error.txt
echo >> ${RTDRTMP}/email_error.txt

echo >> ${RTDRTMP}/email_error.txt
if [ -s ${RTDRTMP}/ERROR.SQLCMD ]; then
	echo "Sqlcmd Error. Check your DB connection!" >> ${RTDRTMP}/email_error.txt
fi
echo >> ${RTDRTMP}/email_error.txt


cat ${RTDRTMP}/email_error.txt | mail -s "ERROR: RT-DP running into issue from $(hostname) at ${BKTIME} on ${BKDATE}" \
	-aFrom:"${FROMMAIL}" \
	-aReply-to:"${ADMINMAIL}" \
	${ADMINMAIL} ${OTHERMAIL}

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Email sent!
echo
