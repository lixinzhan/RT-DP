#!/bin/bash
#

source ./env.dcmtk

#
# generate dcm file for dcmtk query
#
#dump2dcm ./query_uid.dump query_uid.dcm

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Starting DICOM Retrieval ...
echo

tstart=`date +%s`

#
# read from file plan_uid.list with format for DICOM Plan, SSet, and CT
# 	PatientId, CourseId, PlanSetupId, PlanSetupSer, PlanSeriesInstUID, SSetSeriesInstUID, CTSeriesInstUID \
#		StructureSetId, ImageId, NoFractions, TotalDose
#
# read from file refimage_uid.list with format below for DICOM RI
#	PatientId, CourseId, PlanSetupId, PlanSetupSer, RISeriesUID
#
# DCM files below will be retrieved through file copy via ehelper:
# * RGSC signals from CT
# * Teatment records
#

#chmod -R 744 ${RTDRPATH}/Data/DICOM${DAY3TAG}
#rm -rf ${RTDRPATH}/Data/DICOM${DAY3TAG}
chmod -R 744 ${RTDRPATH}/Data/DICOM*
rm -rf ${RTDRPATH}/Data/DICOM.OLD2
mv ${RTDRPATH}/Data/DICOM.OLD ${RTDRPATH}/Data/DICOM.OLD2
mv ${RTDRPATH}/Data/DICOM     ${RTDRPATH}/Data/DICOM.OLD
mkdir -p ${RTDRPATH}/Data/DICOM
touch ${RTDRPATH}/Data/DICOM/__RTDR_${DATESTAMP}${TIMESTAMP:0:4}__


#tail -n +3 ${SQLOUTPATH}/PlanSSetImgUID.csv | awk -F, -v OFS=',' '{print "ID"$1, $2, $3, $4, $5, $11, $15}' | sort | uniq > ${SQLOUTPATH}/_plansuid.list
#tail -n +3 ${SQLOUTPATH}/RefImgUID.csv | awk -F, -v OFS=',' '{print "ID"$1, $2, $3, $4, $6}' | sort | uniq > ${SQLOUTPATH}/refimguid.list

tail -n +3 ${SQLOUTPATH}/PlanSSetImgUID.csv | awk -F, '{print $1}' | sort | uniq > ${SQLOUTPATH}/_patient4suid.list

echo $DATESTAMP $TIMESTAMP > $RTDRTMP/movescu.log
COUNTER_Q=0
for patientid in `cat ${SQLOUTPATH}/_patient4suid.list`
do
	echo `date '+%Y%m%d %H:%M:%S'`  working on $patientid ...
	echo `date '+%Y%m%d %H:%M:%S'`  working on $patientid ... >> $RTDRTMP/movescu.log

	# create folder for dcm storage if not exist yet.
	#OUTPUTDIR=${RTDRPATH}/Data/DICOM${DAY3TAG}/`echo ${patientid:2}`
	OUTPUTDIR=${RTDRPATH}/Data/DICOM/`echo ${patientid:2}`
	mkdir -p $OUTPUTDIR

	# get SeriesUID for Plan, StructureSet, and Planning CT
	grep $patientid ${SQLOUTPATH}/PlanSSetImgUID.csv > ${OUTPUTDIR}/suid.tmp
	cp ${OUTPUTDIR}/suid.tmp ${OUTPUTDIR}/_dcm.info
	awk -F, -v OFS=',' '{print "RP", $5,  $16}'  ${OUTPUTDIR}/suid.tmp | sort | uniq >  ${OUTPUTDIR}/_suid.list
	awk -F, -v OFS=',' '{print "RS", $11, $17}' ${OUTPUTDIR}/suid.tmp | sort | uniq >> ${OUTPUTDIR}/_suid.list
	awk -F, -v OFS=',' '{print "CT", $15, $18}' ${OUTPUTDIR}/suid.tmp | sort | uniq >> ${OUTPUTDIR}/_suid.list

	# get SeriesUID for Reference Images, i.e., DRR
	grep $patientid ${SQLOUTPATH}/RefImgUID.csv > ${OUTPUTDIR}/suid.tmp
	echo " " >> ${OUTPUTDIR}/_dcm.info
	cat ${OUTPUTDIR}/suid.tmp >> ${OUTPUTDIR}/_dcm.info
	awk -F, -v OFS=',' '{print "RI", $6, $10}' ${OUTPUTDIR}/suid.tmp | sort | uniq >> ${OUTPUTDIR}/_suid.list
	rm ${OUTPUTDIR}/suid.tmp


	# # get SeriesUID for Motion Tracking, only MP and MW from CT will be retrieved.
	# grep $patientid ${SQLOUTPATH}/MotionTrackingUID.csv | grep RGSC > ${OUTPUTDIR}/suid.tmp
	# echo " " >> ${OUTPUTDIR}/_dcm.info
	# cat ${OUTPUTDIR}/suid.tmp >> ${OUTPUTDIR}/_dcm.info
	# awk -F, -v OFS=',' '{print $9, $6}' ${OUTPUTDIR}/suid.tmp | sort | uniq >> ${OUTPUTDIR}/_suid.list
	# rm ${OUTPUTDIR}/suid.tmp

	# # get SeriesUID for TreatmentRecord
	# grep $patientid ${SQLOUTPATH}/TreatmentRecordUID.csv > ${OUTPUTDIR}/suid.tmp
	# echo " " >> ${OUTPUTDIR}/_dcm.info
	# cat ${OUTPUTDIR}/suid.tmp >> ${OUTPUTDIR}/_dcm.info
	# awk -F, -v OFS=',' '{print "RT", $7}' ${OUTPUTDIR}/suid.tmp | sort | uniq >> ${OUTPUTDIR}/_suid.list
	# rm ${OUTPUTDIR}/suid.tmp

	# if there is no change, simply copy from existing backup
	OLDOUTPUTDIR=${RTDRPATH}/Data/DICOM.OLD/`echo ${patientid:2}`
	RPCNT0=`ls -lq $OLDOUTPUTDIR/RP* 2>/dev/null | wc -l`
        RPCNT1=`grep RP $OUTPUTDIR/_suid.list 2>/dev/null | wc -l`
	RSCNT0=`ls -lq $OLDOUTPUTDIR/RS* 2>/dev/null | wc -l`
        RSCNT1=`grep RS $OUTPUTDIR/_suid.list 2>/dev/null | wc -l`
	RICNT0=`ls -lq $OLDOUTPUTDIR/RI* 2>/dev/null | wc -l`
        RICNT1=`grep RI $OUTPUTDIR/_suid.list 2>/dev/null | wc -l`
	SUIDMATCH=`cmp --silent -- "$OUTPUTDIR/_suid.list" "$OLDOUTPUTDIR/_suid.list" ; echo $?`
	echo "                  RP/RS/RI OLD vs NEW: $RPCNT0/$RSCNT0/$RICNT0 vs $RPCNT1/$RSCNT1/$RICNT1; SUIDMATCH: $SUIDMATCH" 

	DO_COPY=true
	if [ $SUIDMATCH -ne 0 ];    then DO_COPY=false; fi
        if [ $RPCNT0 -ne $RPCNT1 ]; then DO_COPY=false; fi
        if [ $RSCNT0 -ne $RSCNT1 ]; then DO_COPY=false; fi
        if [ $RICNT0 -ne $RICNT1 ]; then DO_COPY=false; fi

	if $DO_COPY; then
		echo "                  No change. Copy from existing backups!"
		echo "                  No change. Copy from existing backups!" >> $RTDRTMP/movescu.log
		cp -rf $OLDOUTPUTDIR/* $OUTPUTDIR
		continue
	fi


	#
	# query DICOM RP, SSet, CT, RefImg, <del>MotionTracking, and TreatmentRecord using DCMTK</del>
	#
	for suid in `awk -F, '{print $2}' ${OUTPUTDIR}/_suid.list | uniq`
	do
		MODELITY=`grep $suid ${OUTPUTDIR}/_suid.list | awk -F, '{print $1}' | uniq`
		echo "DICOM $MODELITY query $suid ..."
		echo "Processing $MODELITY with $suid ..." >> $RTDRTMP/movescu.log
		movescu -v -P $QSERIES -k 0020,000e=${suid} $PACS4R -od $OUTPUTDIR >> $RTDRTMP/movescu.log 2>&1
	done
	COUNTER_Q=$((COUNTER_Q+1))
done

tend=`date +%s`
echo
echo DICOM Retrieval Done!
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  DICOM_Queried/Total: $COUNTER_Q / `cat ${SQLOUTPATH}/_patient4suid.list | wc -l`
echo
echo Query start at: $tstart
echo Query end at:   $tend
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  DICOM query done with running time: $((($tend-$tstart+30)/60)) min
