<h2>A Disaster Response Plan for Radiation Oncology in GRRCC</h2>


<h3>Instroduction</h3>

Ransomware is an increasing threat for continuous radiation treatment in fighting cancer and data breaches in patient privacy. 
More and more cancer centres have suffered from Ransomware which results in downtime from weeks to months, together with patient information leaking to the public.


<h3>GRRCC Current Network Infrastructure</h3>

* Network and security centrally managed by GRH hospital IS deparment
* User access managed by IS through Active Directory in a single domain grhosp.com
* DNS is managed by GRH IS
* Majority of GRRCC servers are VMs on two VxRail clusters
* GRRCC servers are on the domain in the 112 vLan (xxx.xxx.112.0/22)
* Most servers are assigned with IP within xxx.xxx.115.*
* Backup is based on Veeam. VBR is on the domain (will be off); Repo is accessible from the network (to be isolated soon).
* No downtime procedure exists that can tolerate the current cybersecurity threat yet.
* Citrix access to Aria/Eclipse
* FAS are physical servers provided by Varian, on GRH network
* Five TrueBeams behind Juniper
* Two CT Sims behind firewall(?)
* Lap Laser control PCs exposed to the network
* RGSC PCs are exposed to the network
* Orthovoltage Unit is exposed to the network
* Brachy Treatment Console is behind Juniper (?)


<h3>Risks and Point of Failures Under Cyber Attack</h3>

* Backup VBR is on domain. If VBR is compromised, the backup infrastructure is down.
* Repo is not fully isolated, which results in the risk of losing backups
* When system is down, no way is ready to continue treatments

No security configuration can be 100% disaster proof if not fully network isolated and physically locked. We try our best to decrease the risk. 
When disaster happends, we are expecting to be able to continue patient treatment and return to a fully functional RT as soon as possible. 
Our disaster response plan will then includes two components: the Emergency Downtime Procedure and the Disater System Recovery.


<h3>Emergency Downtime Procedure</h3>

Let's assume the worst: we lost VxRail clusters, VBR, DNS and the **Domain**. What is left: Linacs behind Juniper, a copy of immutable backups.
Remember, in this scenario, we lost remote access too, i.e., no remote in or VPN.

Note:
* There is a file based treatment option available for TrueBeam
* File based option relies on domain too
* Varian is able to bypass the domain requirement

During emergency downtime, we will utilize the option of files based treatment option to finish the dose delivery for all patients under treatment.
In this case, Varian is expected to set up an account to bypass the domain requirement. Configuration and preparations below are:

* A half isolated network, Emergency Downtime Network (EDNet) which allows outgoing traffic only. No incoming traffic should be allowed (will it affect DICOM communication?).
* A Linux server, Emergency Downtime Data Server (EDDS), sits in the EDNet, with NIC disabled by default.
* EDDS: Enable NIC
* EDDS: SQL Query Aria DB for patients under treatment and to be treated with treatment approved: Pt info, SSN, Courses, Plans, Schedules
* EDDS: DICOM retrieval for those pts, including RP, CT, Record, RS, RD, RI etc.
* EDDS: SQL Query Aria DB to find out locations for Documents
* EDDS: Copy Documents to EDDS (To confirm Setup Info can also be found in DCM RP).
* EDDS: SQL Query Questionaire for those pts
* EDDS: SQL Query Journal for those pts
* EDDS: SQL Query Prescription for those pts
* EDDS: SQL Query Treatment History for those pts
* EDDS: SQL Query Scheduled Treatments for those pts
* EDDS: Copy the latest Aria DB dump (a cache server might be required)
* EDDS: Disable NIC

During Emergency:
* EDDS: Copy DCM RP to USB
* EDDS: View pt's documents/Questionaire/Hournal/Prescription/Treatment History/Schedules etc
* Linac: Treat pt with the files on USB.
* 

<h3>Disaster System Recovery</h3>
