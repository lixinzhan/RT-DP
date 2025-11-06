# Offline Treatment Procedure

### Acronyms: 
* **I-WS**: Pseudo I: drive workstations
* **I-PF**: pfSense firewall for Pseudo I: drive
* **DP-SV**: RT-DP backup server
* **DP-PF**: pfSense firewall for RT-DP backup server
  
### Settings and Logins
* I-WS ip: xxx.xxx.xxx.102
* Admin/Administrator on I-WS: \*\*\*\#\^W\*\*\*\*\*\*\*\*\#\#
* Emtreat on I-WS: Emtreat
* Linac on VLAN (xxx.xxx.96.0/24); and I-WS on VLAN3 (xxx.xxx.112.0/22)

## Offline treatment steps
1. Copy patient backup zip files from DP-SV to a USB drive
2. Login I-WS using account Emtreat (admin can also be used)
5. Copy zip from USB drive to Psudo I: drive, and unzip the patients to be treated
3. If testing: make dure the test user logs in first to cache credential. In actual emergency treatment, ask a user used the Linac in the last 1 or 2 days to login.
6. Disconnect the Linac from network and connect it to port VLAN of I-PF.
7. Log in Linac with "Working Offline" selected
8. Tools --> File Mode
9. Select: Open Patient
10. Wait for the I: drive showing up
11. Go to I: drive and load the RT Plan for the patient to be treated.
12. Once treatment is done, CBCT should be in the folder having the treatment plan. Treatment records should be in Treatment folder for the corresponding unit.
    

### Linac Juniper IPs:

| Units | HIT | IP |
| --- | --- | ---|
| RT6 | Hxx1483 | xxx.xxx.96.91 |
| RT5 | Hxx1484 | xxx.xxx.96.96 |
| RT4 | Hxxxxxx | xxx.xxx.96.94 |
| RT3 | Hxx2992 | xxx.xxx.96.93 |
| RT2 | Hxx2513 | xxx.xxx.96.90 |
| RT1 | Hxx2276 | xxx.xxx.96.67 |
