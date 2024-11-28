#!/bin/bash -x
#

#
# Using this script to query VMSDBD and transfer patient data to RT-EMR
#

source ./env.orthanc


# Echo (C-Echo) to both local and remote AET. A check should be performed here.
api_echo $AET
api_echo $ART_R


# Get patient list to be DICOM retrieved
#PATIENTLIST=$(${RTEMRPATH}/tmp/PatientList.uniq)

for PATIENTID in `cat ${RTEMRPATH}/tmp/PatientList.uniq`
do
	JSONPT='{"Level":"Study","Query":{"PatientID":"'${PATIENTID}'"}}'
	OBJID=`api_query $AET_R $JSONPT | jq -r '.ID' `
	ANSLIST=`api_query_review answers $OBJID | tr -d "[]" | tr -d '"' | tr -d ',' `

	echo
	echo ===================================================
	echo == Working on Patient: ${PATIENTID}
	echo

	for ANS in ${ANSLIST}
	do
		SI_UID=`api_query_answer $OBJID $ANS | jq '."0020,000d"' | jq '.Value'`

        	# Retrieve (C-Move)
        	JSONSI='{"Level":"Study","Resources":[{"StudyInstanceUID":'${SI_UID}'}],"TargetAet":"'${AET}'","Timeout":'${TIMEOUT}'}'
        	api_move $AET_R $JSONSI
	done
done
