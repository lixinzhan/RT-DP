#!/bin/bash -x
#

#
# Using this script to query VMSDBD and transfer patient data to RT-EMR
#

source ./env.orthanc

#
# test commands
#

# Echo (C-Echo)
api_echo $AET
api_echo $AET_R

echo ==========================================================================

tstart=`date +%s`

# Query (C-Find)
PATIENTID="soo7n721"
JSONIN='{"Level":"Study","Query":{"PatientID":"'${PATIENTID}'"}}'
echo $JSONIN
api_query $AET_R $JSONIN | tee ${RTEMRPATH}/tmp/result.apiquery

OBJID=`jq -r '.ID' ${RTEMRPATH}/tmp/result.apiquery`
ANSLIST=`api_query_review answers $OBJID | tr -d "[]" | tr -d '"' | tr -d ',' `

for ans in ${ANSLIST}
do
	SI_UID=`api_query_answer $OBJID $ans | jq '."0020,000d"' | jq '.Value'`

	# Retrieve (C-Move)
	JSONIN='{"Level":"Study","Resources":[{"StudyInstanceUID":'${SI_UID}'}],"TargetAet":"RTEMR_DV","Timeout":'${TIMEOUT}'}}'
	echo $JSONIN
	api_move $AET_R $JSONIN
done

tend=`date +%s`
echo Start at: $tstart
echo End at:   $tend
echo Run time: $(($tstart-$tend))
echo Run time: $((tstart-tend))
echo Run time: $( echo "$tend - $tstart" | bc -l )
