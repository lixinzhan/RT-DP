#!/bin/bash
#

# The main entry to call other scripts

RTDRPATH=$(dirname $(realpath $(dirname "${BASH_SOURCE[0]}")))
echo RTDRPATH: $RTDRPATH

# run everything inside the bin folder
cd ${RTDRPATH}/bin

# initialize 
./initialize.sh 

source ./env.common
source ./env.network

# LOGFILE=${RTDRPATH}/Data/log/rtdr-${DATESTAMP}.log

#-------------------------------------------------------------

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  RT-DP Scirpt Starts | tee ${LOGFILE}
echo

#-------------------------------------------------------------

#
# Enable NIC facing Varian servers
#
#     ** /sbin/ip should be added to /etc/sudoer for executing w/o password **
#
enable_network 2>&1 | tee -a ${LOGFILE}

#-------------------------------------------------------------

# SQL Query ARIA DB
./query_db.sh 2>&1 | tee -a ${LOGFILE}

# Extract doc/pdf and DCM file locations and send the list to ehelper
./send_fileloc.sh 2>&1 | tee -a ${LOGFILE}

# DICOM Query/Retrieval from ARIA DICOM DB Service
t_querystart=`date +%s`
./query_dcm.sh 2>&1 | tee -a ${LOGFILE}
t_queryend=`date +%s`
tsec_q=$(($t_queryend-$t_querystart))
echo "DICOM query time (seconds): $tsec_q" | tee -a ${LOGFILE}

# Make sure there are enough time for EHELPER to have data ready!
if (( tsec_q < 3600 )); then
	disable_network 2>&1 | tee -a ${LOGFILE}
	echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'` Sleeping for $(((3600-$tsec_q)/60)) minutes ... | tee -a ${LOGFILE}
	sleep $((3600-$tsec_q))
	enable_network 2>&1 | tee -a ${LOGFILE}
fi

# Copy doc/pdf and DCM from ehelper
./recv_files.sh 2>&1 | tee -a ${LOGFILE}

# Disable network while orgnizing data
disable_network 2>&1 | tee -a ${LOGFILE}

# Organize files to patient based
./organize_files.sh 2>&1 | tee -a ${LOGFILE}

# Enable network for zip file uploading
enable_network 2>&1 | tee -a ${LOGFILE}

# Email running result
./email_result.sh 2>&1 | tee -a ${LOGFILE}

# upload the processed zip file to ehelper
./upload_zip.sh 2>&1 | tee -a ${LOGFILE}

#-------------------------------------------------------------

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  RT-DP Scirpt Done Running! | tee -a ${LOGFILE}
echo

#-------------------------------------------------------------

#
# Disconnect Network
#
disable_network 2>&1 | tee -a ${LOGFILE}

# finalize script
./finalize.sh 2>&1 | tee -a ${LOGFILE}

