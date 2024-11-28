# About TrueBeam File Mode (treating when OIS (ARIA / MOSAIQ) is not connected)

_Varian Knowledge Base 000004185_

Applies to : TrueBeam v2.0 - v4.1 ARIA OIS RTM v11 - v18.0

### About File Mode: 

* File Mode provides a way to treat a patient or perform QA using DICOM files, without the connection to OIS (Oncology Information System). Therefore if the OIS is down, File Mode is an alternative option to treat patients
* File Mode requires patient DICOM files to be available
* File Mode only handles one plan at a time
* File Mode has some risks, such as the potential to treat the wrong patient, wrong anatomy or wrong field, if care is not taken

### To use File Mode the following is required:

* DICOM Plan files uploaded to the I:drive. These must have been exported from the OIS in advance
* Access to the network I: drive (in order to access Patient DICOM files) from the TrueBeam
* Access to OSP/VSP for User Rights
    - If OSP is offline, credentials are held / cached locally on the TrueBeam or 5 days
    - If the TrueBeam needs to re-authenticate and can’t find the OSP, after a timeout of a few minutes, a work offline box pops up
    - This makes the machine use the local credentials


__If the network is down, or there is no connectivity to the I:drive, or the DICOM Plan files were not exported from the OIS system in advance, then there is no workaround to treat patients on the TrueBeam__

### Additional Information :

If TrueBeam System Administration option Allow Unapproved Plans is set to NO, all plans must be Treatment Approved to run in File Mode

### Reference documentation:

* TrueBeam 2.7 MR3 Instructions For Use  
* TrueBeam v3.0 Instructions For Use
* TrueBeam v4.0 Instructions for Use
* TrueBeam v4.1 Instructions for Use
