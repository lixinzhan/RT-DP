#!/bin/bash -x
#

PACSINFO=' -aet RTDR_TK -aec VMSDBD xxx.xxx.115.102 105 '
QPATIENT='-k (0008,0052)=PATIENT'
QSTUDY='-k (0008,0052)=STUDY'
QSERIES='-k (0008,0052)=SERIES'
QIMAGE='-k (0008,0052)=IMAGE'

echo QSTUDY:  $QSTUDY
echo QSERIES: $QSERIES

#
# generate dcm file for query
#
dump2dcm ./query.dump query.dcm

#
# findscu: study
#
findscu -S ${QSTUDY}  ${PACSINFO} query.dcm > study.tmp 2>&1

cat study.tmp | tr -d '\000' | grep '0020,000d' | awk -F'[][{}]' '{print $2}' > study.list

#
# findscu: series
#
QSTUDYINS="-k (0020,000d)=`tail -1 study.list`"
findscu -S ${QSERIES} ${QSTUDYINS} ${PACSINFO} query.dcm > series.tmp 2>&1

cat series.tmp | tr -d '\000' | grep '0020,000e' | awk -F'[][{}]' '{print $2}' > series.list


#
# findscu: image
#
QSERIESINS="-k (0020,000d)=`tail -1 series.list`"
findscu -S ${QIMAGE} ${QSERIESINS} ${PACSINFO} query.dcm # > images.tmp 2>&1


tstart=`date +%s`
#
# movescu
#
PACSINFO=' -aet RTDR_TK --port 4042 -aec VMSDBD xxx.xxx.115.102 105 '
QPATIENT="-k 0008,0052=PATIENT"
PATIENTID="soo7n721"
QPATIENTID="-k 0010,0020=$PATIENTID"

for studyins in `cat study.list`
do
	echo Current StudyInstance: $studyins
	# QSERIESINS="-k 0020,000d=`tail -1 series.list`"
	QSTUDYINS="-k 0020,000d=$studyins"
	
	OUTDIR="$PATIENTID/SI_$studyins"

	mkdir -p $OUTDIR
	movescu -d -P $QPATIENT $QMRN $QSTUDYINS ${PACSINFO} -od $OUTDIR
done


tend=`date +%s`

echo Start at: $tstart
echo End at:   $tend
echo Run time: $(($tend-$tstart))
echo Run time: $((tend-tstart))
echo Run time: $( echo "$tend - $tstart" | bc -l )

