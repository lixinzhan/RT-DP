#!/bin/bash
#

source ./env.email

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Sending email to confirm data retrieved ...
echo

echo ">>> $(hostname)  ${DATESTAMP}-${TIMESTAMP} <<<" > ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "Patients data retrieved and archived to files below:" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
cd ${RTDRARXIV} && ls -lh | awk '{print $5, "\t", $9}' | grep $(hostname)-${DATESTAMP} >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "** If no file listed or file sizes are not reasonable, please check your RT-DP system !!!" >> ${RTDRTMP}/email.txt
echo "** Files can be accessed on ${EHLP_SERVER} in folder ${EHLP_DATA}" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "Time information for key steps: " >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
cat ${LOGFILE} | grep INFO_TIME | sed 's/INFO_TIME: //g' >> ${RTDRTMP}/email.txt


cat ${RTDRTMP}/email.txt | mail -s "RT-DP running result from $(hostname) at ${TIMESTAMP} on ${DATESTAMP}" \
	-aFrom:"${FROMMAIL}" \
	-aReply-to:"${ADMINMAIL}" \
	${ADMINMAIL} ${OTHERMAIL}

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Email sent!
echo
