#!/bin/bash
#

source ./env.ehelper

echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Organizing Retrieved Files ...
echo

mv $RTDRPATH/Patients/README.md $RTDRTMP/readme.pt.backup
chmod -R 744 $RTDRPATH/Patients/*
rm -rf $RTDRPATH/Patients/*
mv $RTDRTMP/readme.pt.backup $RTDRPATH/Patients/README.md
touch $RTDRPATH/Patients/__RTDR_${DATESTAMP}__

# Copy SQL Query Results
mkdir -p ${RTDRPATH}/Patients/SQLResults
cp -rf ${SQLOUTPATH}/* ${RTDRPATH}/Patients/SQLResults

# loop through all patients
for patientid in `cat ${SQLOUTPATH}/_patient_list.uniq`
do
	echo `date '+%Y%m%d %H:%M:%S'` working on $patientid ...
	# create patient folder
	PTFOLDER=${RTDRPATH}/Patients/${patientid}
	mkdir -p $PTFOLDER

	#
	# Copy Treatment Required DICOM files
	#
	PTDCMDATA=${RTDRPATH}/Data/DICOM${DAY3TAG}/${patientid}
	if [ -d ${PTDCMDATA} ]; then
		# mkdir -p $PTFOLDER/PLAN
		# cp -rf ${PTDCMDATA}/* $PTFOLDER/PLAN
		cp -rf ${PTDCMDATA} $PTFOLDER
		cd $PTFOLDER && mv ${patientid} PLAN
	fi

	#
	# Add extension .dcm to all DICOM files, and add plan info for RP files
	#
	if [ -d ${PTFOLDER}/PLAN ]; then
		cd ${PTFOLDER}/PLAN
		for dcmfile in `ls -I "_*" `
		do
			if [[ ${dcmfile} != *.dcm ]]; then
				mv ${dcmfile} ${dcmfile}.dcm
			fi
		done

		rm -rf ${RTDRTMP}/tmprp.csv
		touch  ${RTDRTMP}/tmprp.csv
		for rpfile in `ls RP.*.dcm`
		do
			dcmdump ${rpfile} > ${RTDRTMP}/rp.dump

			# extract PlanSetupId from dicom dump file
			ptid=`grep '(0010,0020)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2}' | \
				tr -d [:space:] | tr [:punct:] '_'`
			rpid=`grep '(300a,0002)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2}' | \
				tr -d [:space:] | tr [:punct:] '_'`
			mv ${rpfile} ${ptid}.${rpid}.${rpfile}

			# extract other info from dicom rp dump file
			grep '(0010,0020)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}'  > ${RTDRTMP}/rp.xtr  # patientid
			grep '(0010,0030)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # DOB
			grep '(300a,0002)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # planname
			grep '(300a,0006)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # RTPlanDate
			grep '(300e,0002)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # ApprvStatus
			grep '(0008,1048)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # Physician
			grep '(0002,0003)' ${RTDRTMP}/rp.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/rp.xtr  # MediaStorageSOPInstanceUID

			# convert output to csv format
			tr '\n' ' ' < ${RTDRTMP}/rp.xtr >> ${RTDRTMP}/tmprp.csv
			echo >> ${RTDRTMP}/tmprp.csv
		done

		echo "PatientId,DOB,PlanName,PlanDate,Approval,Physician,MediaStorageInstanceUID"  > ${PTFOLDER}/PLAN/Plans.csv
		echo "---------,---,--------,--------,--------,---------,-----------------------" >> ${PTFOLDER}/PLAN/Plans.csv
		cat ${RTDRTMP}/tmprp.csv >> ${PTFOLDER}/PLAN/Plans.csv
	fi

	#
	# Copy TFH/Tracking DICOM files
	#
	#    Note: There are very rare cases that patient has 2+ imagedir entries. 
	#          We assume the ptdcmloc.id is the same, hence `uniq`
	#          Example: ooee2558/_45160 on both imagedir1 and imagedir2
	grep -i ID${patientid} ${SQLOUTPATH}/ImgFileLocation.csv | \
		awk -F "\\" '{print $NF}' | uniq > $RTDRTMP/ptdcmloc.id
	if [ -s $RTDRTMP/ptdcmloc.id ]; then
		cp -rf $RTDRDATA/EHLPDCM${DAY3TAG}/DICOM/`cat $RTDRTMP/ptdcmloc.id`/* $PTFOLDER
	fi

	#
	# Extract info from DICOM of Treatment Field Record
	#
	if [ -s $PTFOLDER/TFH ]; then
		rm -rf $RTDRTMP/tmp.csv
		touch  $RTDRTMP/tmp.csv
		for tfhfile in `ls $PTFOLDER/TFH/R*dcm*`
		do
			# echo working on $tfhfile ...
			dcmdump ${tfhfile} > ${RTDRTMP}/tfh.dump

			# extract info from dicom dump file
			grep '(3008,0250)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}'  > ${RTDRTMP}/tfh.xtr # Tx Date
			grep '(3008,0251)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Tx Time
			grep '(0010,0020)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Pt MRN
			grep '(0010,0010)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Pt Name
			grep '(0008,0060)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Modality
			grep '(300a,00ce)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Tx Delivery Type
			if [ $(grep -ic '(300a,00c6)' ${RTDRTMP}/tfh.dump) -ge 1 ]
			then
				grep '(300a,00c6)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Radiation Type
			else
				echo "," >> ${RTDRTMP}/tfh.xtr  # when no entry is found, such as brachy records.
			fi
			grep '(300a,00b2)' ${RTDRTMP}/tfh.dump | grep SH | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Tx Machine Name
			grep '(3008,0022)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Current Fx num
			grep '(300a,0078)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # Planned Fx num
			grep '(300a,00c4)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # BeamType
			grep '(300a,00c2)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # BeamName
			echo $(basename ${tfhfile}) "," >> ${RTDRTMP}/tfh.xtr
			grep '(300a,0114)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/tfh.xtr # EnergyMode
			grep '(3002,0052)' ${RTDRTMP}/tfh.dump | awk -F "[][{}]" '{print $2    }' >> ${RTDRTMP}/tfh.xtr # FluenceMode; may not exist, hence the last column.
			
			# convert output to csv format
			tr '\n' ' ' < ${RTDRTMP}/tfh.xtr >> ${RTDRTMP}/tmp.csv
			echo >> ${RTDRTMP}/tmp.csv

			mv ${tfhfile} ${tfhfile}.dcm
		done

		echo "TxDate,TxTime,PatientId,FullName,Modality,DeliveryType,RadiationType,TxMachine,CurrentFx,PlannedFx,BeamType,BeamName,TFH_File,Energy,FluenceMode"  > ${PTFOLDER}/TFH/TFH.csv
		echo "------,------,---------,--------,--------,------------,-------------,---------,---------,---------,--------,--------,--------,------,-----------" >> ${PTFOLDER}/TFH/TFH.csv
		sort -t ',' -k 1,1 -k 2,2 ${RTDRTMP}/tmp.csv >> ${PTFOLDER}/TFH/TFH.csv 
		# rm -rf ${RTDRTMP}/tmp.csv
	fi

	#
	# Extract info for Motion Tracking files
	#
	if [ -s $PTFOLDER/Tracking ]; then
		rm -rf $RTDRTMP/tmp.csv
		touch  $RTDRTMP/tmp.csv
		for motionfile in `ls $PTFOLDER/Tracking/M*dcm* `
		do
			# dcho working on $motionfile ...
			dcmdump ${motionfile} > ${RTDRTMP}/motion.dump

			# extract info from the dicom dump file
			grep '(0008,002a)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2,","}'  > ${RTDRTMP}/motion.xtr # AcquisitionDateTime
			grep '(0010,0020)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/motion.xtr # Pt MRN
			grep '(0010,0010)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/motion.xtr # Pt Name
			grep '(0008,0060)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/motion.xtr # Modality
			grep '(0020,0010)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2,","}' >> ${RTDRTMP}/motion.xtr # StudyID
			echo $(basename ${motionfile}) "," >> ${RTDRTMP}/motion.xtr
			grep '(0008,1010)' ${RTDRTMP}/motion.dump | awk -F "[][{}]" '{print $2    }' >> ${RTDRTMP}/motion.xtr # StationName, may not exist in some MP files, hence the last column.

			# convert output to csv format
			tr '\n' ' ' < ${RTDRTMP}/motion.xtr >> ${RTDRTMP}/tmp.csv
			echo >> ${RTDRTMP}/tmp.csv

			mv ${motionfile} ${motionfile}.dcm
		done

		echo "AcqDateTime,PatientId,FullName,Modality,StudyID,MotionFile,StationName"  > ${PTFOLDER}/Tracking/Motion.csv
		echo "-----------,---------,--------,--------,-------,----------,-----------" >> ${PTFOLDER}/Tracking/Motion.csv
		sort -t ',' -k 1,1 ${RTDRTMP}/tmp.csv >> ${PTFOLDER}/Tracking/Motion.csv
	fi


	#
	# Copy Documents
	#
	# grep -i ID${patientid} ${SQLOUTPATH}/DocFileLocation.csv | \
	# 	awk -F, '{print $4}' | rev | \
	# 	awk -F "\\" '{print $1}' | rev > $RTDRTMP/ptdocloc.fn
	grep -i ID${patientid} ${SQLOUTPATH}/DocFileLocation.csv > $RTDRTMP/ptdocloc.csv
	if [ -s $RTDRTMP/ptdocloc.csv ]; then
		mkdir -p $PTFOLDER/DOC
		head -2 ${SQLOUTPATH}/DocFileLocation.csv > $PTFOLDER/DOC/_ptdocloc.csv
		grep -i ID${patientid} ${SQLOUTPATH}/DocFileLocation.csv >> $PTFOLDER/DOC/_ptdocloc.csv

		awk -F, '{printf("%s :  %-32s %s\n", $4, $6, $8);}' $RTDRTMP/ptdocloc.csv | rev | \
			awk -F "\\" '{print $1}' | rev > $PTFOLDER/DOC/_file_type.txt
		awk -F, '{print $4}' $RTDRTMP/ptdocloc.csv | rev | \
			awk -F "\\" '{print $1}' | rev > $RTDRTMP/ptdocloc.fn

		for docfile in `cat $RTDRTMP/ptdocloc.fn`
		do 
			cp -rf $RTDRDATA/EHLPDOC${DAY3TAG}/Documents/$docfile $PTFOLDER/DOC
		done
	fi

	#
	# RPR
	#
	grep -i ${patientid} ${SQLOUTPATH}/RPRContents.csv > $RTDRTMP/ptrpr.csv
	if [ -s $RTDRTMP/ptrpr.csv ]; then
		mkdir -p $PTFOLDER/DOC
		head -2 $SQLOUTPATH/RPRContents.csv > $PTFOLDER/DOC/RPR.csv
		grep -i ${patientid} $SQLOUTPATH/RPRContents.csv >> $PTFOLDER/DOC/RPR.csv
	fi

	#
	# Journal
	#
	grep -i ${patientid} ${SQLOUTPATH}/Journal.csv > $RTDRTMP/ptjournal.csv
	if [ -s $RTDRTMP/ptjournal.csv ]; then
		mkdir -p $PTFOLDER/DOC
		head -2 $SQLOUTPATH/Journal.csv > $PTFOLDER/DOC/Journal.csv
		grep -i ${patientid} $SQLOUTPATH/Journal.csv >> $PTFOLDER/DOC/Journal.csv
	fi

	#
	# Prescription
	#
	grep -i ${patientid} ${SQLOUTPATH}/Prescription.csv > $RTDRTMP/ptpres.csv
	if [ -s $RTDRTMP/ptpres.csv ]; then
		mkdir -p $PTFOLDER/DOC
		head -2 $SQLOUTPATH/Prescription.csv > $PTFOLDER/DOC/Prescription.csv
		grep -i ${patientid} $SQLOUTPATH/Prescription.csv >> $PTFOLDER/DOC/Prescription.csv
	fi

	#
	# Treatment Schedule
	#
	grep -i ${patientid} ${SQLOUTPATH}/TreatmentScheduledNext7Days.csv > $RTDRTMP/txschd.csv
	if [ -s $RTDRTMP/txschd.csv ]; then
		mkdir -p $PTFOLDER/DOC
		head -2 $SQLOUTPATH/TreatmentScheduledNext7Days.csv > $PTFOLDER/DOC/TxSchdNext7Days.csv
		grep -i ${patientid} $SQLOUTPATH/TreatmentScheduledNext7Days.csv >> $PTFOLDER/DOC/TxSchdNext7Days.csv
	fi
done


#
# Compress to zip for every ${ZIPBATCHSIZE} number of patients
#

echo
echo `date '+%Y-%m-%d %H:%M:%S'`  Starting Archiving Retrieved Files ...
echo

echo $DATESTAMP $TIMESTAMP > $RTDRTMP/zip.log

count=0
PIDLIST=${ZIPCOMMON}.txt
touch ${PIDLIST}
for patientid in `cat ${SQLOUTPATH}/_patient_list.uniq`
do
	count=$((count+1))
	if (( $count%$ZIPBATCHSIZE == 1 )); then
		ZIPFILE=${ZIPCOMMON}-${patientid}.zip
		echo ------------------------------------------- >> ${PIDLIST}
		echo Patients in $(basename ${ZIPFILE}): >> ${PIDLIST}
	fi
	echo Patient Count:  $count      >> $RTDRTMP/zip.log
	echo Patient MRN/ID: $patientid  >> $RTDRTMP/zip.log
	echo Archiving to:   $ZIPFILE    >> $RTDRTMP/zip.log
        cd $RTDRPATH && zip -r ${ZIPFILE} Patients/$patientid >> $RTDRTMP/zip.log 2>&1
	echo $count$'\t'$patientid >> ${PIDLIST}
done


echo
echo INFO_TIME: `date '+%Y-%m-%d %H:%M:%S'`  Retrieved Files Organized and Archived!
echo
