#!/bin/bash -x
#

PACSINFO=' -aet RTEMR_DV -aec VMSDBD 172.17.115.172 105 '
QPATIENT='-k (0008,0052)=PATIENT'
QSTUDY='-k (0008,0052)=STUDY'
QSERIES='-k (0008,0052)=SERIES'
QIMAGE='-k (0008,0052)=IMAGE'

echo QSTUDY:  $QSTUDY
echo QSERIES: $QSERIES

#
# generate dcm file for query
#
dump2dcm ./query_uid.dump query_uid.dcm

#
# movescu
#
tstart=`date +%s`

QSERIES='-k 0008,0052=SERIES'
PACSMOVE=' -aet RTEMR_DV --port 4242 -aec VMSDBD 172.17.115.172 105 '

rm -rf series.tmp
for seriesuid in `cat SeriesUID.list`
do
	findscu -S ${QSERIES}  -k "(0020,000e)=${seriesuid}" ${PACSINFO} query_uid.dcm  > series_this.tmp 2>&1
	cat series_this.tmp >> series.tmp
	PatientID=`cat series_this.tmp | tr -d '\000' | grep "0010,0020" | awk -F'[][{}]' '{print $2}' `
	echo PatientID: $PatientID
	Modality=`cat series_this.tmp | tr -d '\000' | grep "0008,0060" | awk -F'[][{}]' '{print $2}' `
	echo Modality: $Modality
	# OUTPUTDIR=$PatientID/$Modality
	OUTPUTDIR="./DCMOUT/"
	mkdir -p $OUTPUTDIR
	movescu -d -P $QSERIES -k 0020,000e=${seriesuid} ${PACSMOVE} -od $OUTPUTDIR
done

tend=`date +%s`

echo Start at: $tstart
echo End at:   $tend
echo Run time: $(($tend-$tstart))



# #
# # movescu
# #
# PACSINFO=' -aet RTEMR_DV --port 4242 -aec VMSDBD 172.17.115.172 105 '
# QPATIENT="-k 0008,0052=PATIENT"
# PATIENTID="soo7n721"
# QPATIENTID="-k 0010,0020=$PATIENTID"
# 
# for studyins in `cat study.list`
# do
# 	echo Current StudyInstance: $studyins
# 	# QSERIESINS="-k 0020,000d=`tail -1 series.list`"
# 	QSTUDYINS="-k 0020,000d=$studyins"
# 	
# 	OUTDIR="$PATIENTID/SI_$studyins"
# 
# 	mkdir -p $OUTDIR
# 	movescu -d -P $QPATIENT $QMRN $QSTUDYINS ${PACSINFO} -od $OUTDIR
# done
# 
