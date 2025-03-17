#!/bin/bash
#

source ./env.sql

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Starting Aria DB Queries ...
echo

###############################################
# Queries
###############################################

sql_exec "${RTDRPATH}/SQLScripts/TreatmentDeliveredLast7Days.sql"
sql_exec "${RTDRPATH}/SQLScripts/TreatmentScheduledNext7Days.sql"
sql_exec "${RTDRPATH}/SQLScripts/CTSimLast15Days.sql"
sql_exec "${RTDRPATH}/SQLScripts/RPRLast60Days.sql"

###############################################
# Retrieving RPR for listed patients
###############################################

# Get MRNList for RPR retrieving
MRNLIST=`tail -n +3 ${SQLOUTPATH}/RPRLast60Days.csv | \
	awk -F, '$18 !~ /1/' | \
	awk -F, '{printf("\"%s\", ",$1);}' | \
	head -c -2` # > ${SQLOUTPATH}/MRNList4RPR.tmp
#MRNLIST=`cat ${SQLOUTPATH}/MRNList4RPR.tmp`
#echo $MRNLIST

# Append MRNList to query script
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/RPRContents.sql | head -n -1 > ${RTDRPATH}/tmp/RPRContents.sql
echo "and pa.PatientId in (${MRNLIST})" >> ${RTDRPATH}/tmp/RPRContents.sql
echo "order by pa.PatientId, q.question_id" >> ${RTDRPATH}/tmp/RPRContents.sql

# Query RPR contents 
sql_exec "${RTDRPATH}/tmp/RPRContents.sql"



#####################################################################################
# Obtain Patient List to Prepare for DICOM, Journal, Prescription, and Demographics
#####################################################################################

# Plan list from TreatmentScheduledNext7Days, TreatmentDeliveredLast7Days, 
#   RPRLast60Days with SimCMUFlag
echo
echo "Generating _patient_list.uniq for Journal query and DICOM retrieving ..."
rm -f ${SQLOUTPATH}/PatientList*

echo "Results from TxScheduled:" > ${SQLOUTPATH}/PatientList
tail -n +3 ${SQLOUTPATH}/TreatmentScheduledNext7Days.csv | \
	awk -F, '{print $1}' >>  ${SQLOUTPATH}/PatientList

echo "Results from TxDelivered:" >> ${SQLOUTPATH}/PatientList
tail -n +3 ${SQLOUTPATH}/TreatmentDeliveredLast7Days.csv | \
	awk -F, '{print $1}' >> ${SQLOUTPATH}/PatientList

echo "Results from CTSim:" >> ${SQLOUTPATH}/PatientList
tail -n +3 ${SQLOUTPATH}/CTSimLast15Days.csv | \
	awk -F, '$16 !~ /^Completed/' | \
	awk -F, '$16 !~ /Unapproved/' | \
	awk -F, '$16 !~ /Retired/' | \
	awk -F, '{print $1}' >> ${SQLOUTPATH}/PatientList

echo "Results from RPR:" >> ${SQLOUTPATH}/PatientList
tail -n +3 ${SQLOUTPATH}/RPRLast60Days.csv | \
	awk -F, '$13 ~ /1/' | \
	awk -F, '{print $1}' >> ${SQLOUTPATH}/PatientList

grep -v 'Results' ${SQLOUTPATH}/PatientList | sort | uniq > ${SQLOUTPATH}/_patient_list.uniq
rm ${SQLOUTPATH}/PatientList


# Assign a variable for the list.
PTIDLIST=`cat ${SQLOUTPATH}/_patient_list.uniq | awk '{printf("\"%s\", ", $1);}' | head -c -2 `

echo PatientList generated and saved in ${SQLOUTPATH}/_patient_list.uniq
echo


###############################################################
# Obtain Patient Demographics
###############################################################

# Append Patient List to demographics query script and perform query
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/Demographics.sql | head -n -1 > ${RTDRPATH}/tmp/Demographics.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/Demographics.sql
echo "order by p.PatientId" >> ${RTDRPATH}/tmp/Demographics.sql
sql_exec "${RTDRPATH}/tmp/Demographics.sql"

###############################################################
# Obtain Patient Emergency Contacts
###############################################################

# Append Patient List to demographics query script and perform query
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/EmergencyContacts.sql | head -n -1 > ${RTDRPATH}/tmp/EmergencyContacts.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/EmergencyContacts.sql
echo "order by p.PatientId" >> ${RTDRPATH}/tmp/EmergencyContacts.sql
sql_exec "${RTDRPATH}/tmp/EmergencyContacts.sql"


###############################################################
# Obtain Journals for patients listed above
###############################################################

# Append Patient List to Journal query script and perform query
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/Journal.sql | head -n -1 > ${RTDRPATH}/tmp/Journal.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/Journal.sql
echo "order by p.PatientId, NoteTime" >> ${RTDRPATH}/tmp/Journal.sql
sql_exec "${RTDRPATH}/tmp/Journal.sql"


###############################################################
# Obtain Prescriptions for patients listed above
###############################################################

# Append Patient List to Prescription query script and perform query
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/Prescription.sql | head -n -1 > ${RTDRPATH}/tmp/Prescription.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/Prescription.sql
echo "order by p.PatientId, c.CourseId" >> ${RTDRPATH}/tmp/Prescription.sql
sql_exec "${RTDRPATH}/tmp/Prescription.sql"

###############################################################
# Obtain Plan List to Prepare for those patients listed above
###############################################################

# append MRN list to the query script for Plan, SSet and CT SeriesUID
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/PlanSSetImgUID.sql | head -n -1 > ${RTDRPATH}/tmp/PlanSSetImgUID.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/PlanSSetImgUID.sql
sql_exec "${RTDRPATH}/tmp/PlanSSetImgUID.sql"

# Query RefImg SeriesUID
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/RefImgUID.sql | head -n -1 > ${RTDRPATH}/tmp/RefImgUID.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/RefImgUID.sql
sql_exec "${RTDRPATH}/tmp/RefImgUID.sql"

# Query MotionTracking SeriesUID
grep -v '^$' ${RTDRPATH}/SQLScripts/MotionTrackingUID.sql | tail -1 > ${RTDRPATH}/tmp/orderby.tmp
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/MotionTrackingUID.sql | head -n -2 > ${RTDRPATH}/tmp/MotionTrackingUID.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/MotionTrackingUID.sql
cat ${RTDRPATH}/tmp/orderby.tmp >> ${RTDRPATH}/tmp/MotionTrackingUID.sql
sql_exec "${RTDRPATH}/tmp/MotionTrackingUID.sql"

# Query TreatmentRecord SeriesUID
grep -v '^$' ${RTDRPATH}/SQLScripts/TreatmentRecordUID.sql | tail -1 > ${RTDRPATH}/tmp/orderby.tmp
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/TreatmentRecordUID.sql | head -n -2 > ${RTDRPATH}/tmp/TreatmentRecordUID.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/TreatmentRecordUID.sql
cat ${RTDRPATH}/tmp/orderby.tmp >> ${RTDRPATH}/tmp/TreatmentRecordUID.sql
sql_exec "${RTDRPATH}/tmp/TreatmentRecordUID.sql"

###############################################################
# Obtain Image and Doc file location for those patients listed above
###############################################################

# append MRN list to query script for Img queries
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/ImgFileLocation.sql | head -n -1 > ${RTDRPATH}/tmp/ImgFileLocation.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/ImgFileLocation.sql
sql_exec "${RTDRPATH}/tmp/ImgFileLocation.sql"

# append MRN list to query script for Doc queries
awk '!/^[[:space:]]*$/' ${RTDRPATH}/SQLScripts/DocFileLocation.sql | head -n -1 > ${RTDRPATH}/tmp/DocFileLocation.sql
echo "and p.PatientId in (${PTIDLIST})" >> ${RTDRPATH}/tmp/DocFileLocation.sql
sql_exec "${RTDRPATH}/tmp/DocFileLocation.sql"

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  DB Queries All Done!
echo
