#!/bin/bash
#

source ./env.ehelper
source ./env.email

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Sending email to confirm data retrieved ...
echo

BKDATE=`echo $DATESTAMP | awk '{print substr($0,1,4)"-"substr($0,5,2)"-"substr($0,7,2)}'`
BKTIME=`echo $TIMESTAMP | awk '{print substr($0,1,2)":"substr($0,3,2)}'`

echo ">>>>>> $(hostname)  ${BKDATE} ${BKTIME} <<<<<<" > ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt

echo "Patients data retrieved and archived to files below:" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
cd ${RTDRARXIV} && ls -lh | awk '{print $5, "  ", $9}' | grep $(basename ${ZIPCOMMON}) >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt

echo "** If no file listed or file sizes are not reasonable, please check your RT-DP system !!!" >> ${RTDRTMP}/email.txt
echo "** Files can be accessed on ${EHLP_SERVER%%.*} in folder ${EHLP_DATA} for routine tests." >> ${RTDRTMP}/email.txt
echo "** Files are available on $(hostname) in folder ${RTDRARXIV} for offline treatment!" >> ${RTDRTMP}/email.txt
echo "** See Offline Tx Steps in: ${DOCROOT}" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt

echo "------------------------------------" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "Time information for key steps: " >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
cat ${LOGFILE} | grep INFO_TIME | sed 's/INFO_TIME: //g' >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt

SVRNAME=$(hostname)
SVRIP=$(ip -br -4 a | grep ${MYNIC} | awk '{print $3}')
SVRMODEL=$(cat /sys/devices/virtual/dmi/id/product_name)
echo "------------------------------------" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "Server: $SVRNAME $SVRIP($MYNIC) $SVRMODEL" >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
echo "Disk space info for which RT-DP is on: " >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt
# CR=$(printf '\r') && echo textfile | sed "s/\$\$CR/g" acts as unix2dos
df -h ${RTDRPATH} >> ${RTDRTMP}/email.txt
echo >> ${RTDRTMP}/email.txt


cat ${RTDRTMP}/email.txt | mail -s "RT-DP running result from $(hostname) at ${BKTIME} on ${BKDATE}" \
	-aFrom:"${FROMMAIL}" \
	-aReply-to:"${ADMINMAIL}" \
	${ADMINMAIL} ${OTHERMAIL}

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Email sent!
echo
