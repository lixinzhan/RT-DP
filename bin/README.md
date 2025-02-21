# Bash Scripts for RT-DP.


*** __CHANGES TO MAKE FOR EVERY NEW DEPLOYMENT__ ***

* **env.base:**

* **env.common:**

* **env.sql:**
	- _DBSVR_: hostname or IP of Aria server

* **env.dcmtk:**
	- _LOCAL_AET_: AET assigned to the RT-DP node. Should be added as an allowed node to Aria VMSDBD.
	- _LOCAL_PORT_: port number assigned for DICOM communication, should be allowed in firewall setup.
	- _REMOTE_AET_: AET for Aria VMSDBD, usually it is directly "VMSDBD" (for Varian system).
	- _REMOTE_IP_: IP address of Aria DB server.
	- _REMOTE_PORT_: port number for DICOM communication, the Aria DB side.

* **env.network:**
	- _MYNIC_: can be found by `ip a`

* **env.ehelper:**
	- Everything except DOC_LIST_FILE and DCM_LIST_FILE

* **env.email:**
  	- _MAILNAME_: e.g. grhosp.on.ca for GRH (if the email address is name@grhosp.on.ca)
  	- _RELAYHOST_: the SMTP server
	- _FROMMAIL_
	- _ADMINMAIL_
	- _OTHERMAIL_

* **base_setup.sh**
  	- __env.email__ should be set before running this script for setting up automatic email correctly.
  	  
* **Aria v15 upgrade date**
	- Starting from v15, Aria documents storage location has been updated and saved in subfolder yyyyQ#. 
	- v15upgrdate has to be updated in SQLScripts/DocFileLocation.sql to find the correct file location.


-------------------------------------

* __To schedule a cron job to such as 19:30, use root account or an user listed in `/etc/cron.allow`__

```
crontab -e

30 19 * * * ${RTEMRPATH}/bin/main_run.sh
```

-------------------------------------

* __Format of script-auth.txt__

```
AURA:  user  pass
ARIA:  user  pass
GPG:   passphrase  pass
```

