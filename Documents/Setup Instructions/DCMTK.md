<h2>DCMTK Usage</h2>

# dcmtk installation

```
sudo apt install dcmtk
```

# generate dcm file from dump for find/query

```
dump2dcm query.dump query.dcm
```

# a simple dump

```
(0002,0010) UI =LittleEndianExplicit  # TransferSyntaxUID

(0008,0052) CS [PATIENT]              # QueryRetrieveLevel
(0010,0020) LO [90000001]             # PatientID
(0020,000d) UI []                     # StudyInstanceUID
(0020,0010) SH []                     # StudyID
(0020,000e) UI []                     # SeriesInstanceUID
(0020,0011) IS []                     # SeriesNumber
(0008,103e) LO []                     # SeriesDescription
(0008,1030) LO []                     # StudyDescription
```

# findscu

```
findscu -S -k 0008,0052=${QueryRetrieveLevel} -k ${OTHER-QUERY-INFO} -aet ${LOCAL-AET} -aec ${TARGET-AET} ${AEC-IP} ${AEC-PORT} query.dcm

-S: use study root information model, instead of -P (patient) -W (worklist), or -O (patient/study only)
QueryRetrieveLevel: PATIENT/STUDY/SERIES/IMAGE
OTHER-QUERY-INFO: to update or provide more info in query.dcm
  0010,0020: PatientID
  0020,000d: StudyInstanceUID
  0020,000e: SeriesInstanceUID
  0008,0018: SOPInstanceUID
  0020,0052: FrameOfReferenceUID
  etc.
```

# movescu
```
movescu -S -k 0008,0052=$QueryRetrieveLevel} -k ${OTHER-QUERY-INFO} -aet ${LOCAL-AET} --port {LOCAL-PORT} -aec ${TARGET-AET} ${AEC-IP} ${AEC-PORT} -od ${OUTDIR}

OUTDIR: output folder for retrieved dicom files
LOCAL-PORT; port used for local aet to communication with target pacs. Usually this info should match the configration in the target node.
```

------------------------------------------------

* Quick Notes:

* FINDSCU

```
findscu -d -P -k "(0008,0052)=STUDY" \
	-k "(0010,0020)=90000001" 
	-k "(0020,000d)=" \
	-aet RTEMR_DV -aec VMSDBD 172.17.115.102 105 \
	> output.tmp 2>&1
cat output.tmp | tr -d '\000' | grep '0020,000d' | awk -F'[][{}]' '{print $2}' > output.sidlist
```

can retrieve StudyInstanceUID (0020,000d). Query/Retrive level must be presented, (0008,0052)=STUDY/SERIES/IMAGE.

OR, create a dump file dump.studyquery
```
[0002,0010) UI =LittleEndianExplicit

(0008,0052) CS [STUDY]
(0010,0020) LO [90000001]
(0020,000d) UI []
```

then

```
dump2dcm dump.studyquery studyquery.dcm
```

then

```
findscu +sr -S -aet RTEMR_DV -aec VMSDBD 172.17.115.102 105 studyquery.dcm
```

and any entries in the dump/dcm file can be replaced with an explicit '-k' switch.


* ECHOSCU

```
echoscu -d -aet RTEMR_DV -aec VMSDBD 172.17.115.102 105
```

is working.
