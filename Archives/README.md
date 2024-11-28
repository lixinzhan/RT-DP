# Place for Archived Patient Data

File Name: 

- `<hostname>-<yyyymmdd>-<hhmm>-<patientid>.zip`

ZIP files are splitted to contained $ZIPBATCHSIZE number of patients to meet USB(FAT32) file size limit.

This also decrease the unzip time when needed. 

Patients in each file can be identified from `<hostname>-<yyyymmdd>-<hhmm>.txt`
