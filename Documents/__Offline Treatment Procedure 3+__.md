# Offline Treatment Procedure for Truebeam 3.0+

* Connect cart to power
* Power on ESXi
* Power on other computers
* Connect management computer to https://<ESXi IP>
* Bring ESXi out of maintenance mode
* Power on **Gateway** --> **Domain Controller** --> **VSP** --> **ARIA** --> **DCM** --> **Console-96** --> **CTX05**
* Confirm they all have network connected
* Test Aria is working on **CTX05**
* Copy DCM files to **VA_TRANSFER**
* Connect TrueBeam to switch
* Login Linac console and start file mode treatment
