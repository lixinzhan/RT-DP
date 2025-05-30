# I-drive Setup -- Essential for File Mode Treatment

A pre-requisite for treatment in DICOM RT mode (TrueBeam) is the existence of I: drive for
DICOM files and later the treatment records. 
When VSP/OIS is not available, there is a high chance that the network has issues, then I: drive is not available too. 

To continue treatment , we need to create an I: drive replacement or faked I: drive.

**Confirm that Therapists, Physicists, Electronics, and Services have the file mode treatment permission**

**For GRRCC: the groups should be: Physicist, Therapist, Adv Therapist, Physics, Student QA, Service.**

## 1a. Windows -- public share with no local account requirement

* create folder VA_TRANSFER, with full permission for everyone. 

![image](images/VA_TRANS%20Permission.png)


* setup share with full permission for everyone. 

![image](images/VA_TRANS%20Properties.png)

* turn off password protected sharing so that **No Account** on the computer is required

![image](images/VA_TRANS%20Sharing%20Settings.png)


## 1b. Ubuntu -- public share with no existing local account requirement

* samba installation 

  ```
  sudo apt install samba
  sudo systemctl enable smbd
  ```

* find the NIC for share and configure `smb.conf`
  ```
  ip a    # find the NIC interface
  sudo vi /etc/samba/smb.conf     # edit file
  ```

  make change in /etc/samba/smb.conf:
  
  `; interfaces = 127.0.0.0/8 eth0` ==> `interfaces = 127.0.0.0/8 IFACE`
  `; bind interfaces only = yes`  ==> `bind interfaces only = yes`
  

* create a VA_TRANSFER public share at the bottom of `/etc/samba/smb.conf`:

  ```
  [VA_TRANSFER]
  path = /home/VA_TRANSFER
  public = yes
  guest only = yes
  force create mode = 0666
  force directory mode = 0777
  browseable = yes
  ```

* create the share folder
 
  ```
  sudo mkdir /home/VA_TRANSFER
  sudo chmod -R ugo+w /home/VA_TRANSFER
  ```

* restart samba service 

  ```
  sudo systemctl restart smbd
  ```

_Note: this share is for the case that guest has no account on the computer. It is NOT secure._

## 2. setup firewall to route vlan 96 and 112

* Configure LAN1 to the vlan that TrueBeam Juniper is on (vlan 96 for GRRCC)

  pfSense --> Interfaces --> LAN

  - Enable Interface
  - IPv4 Configuration Type: Static IPv4
  - IPv4 Address: xxx.xxx.96.1/24
  - IPv4 Upstream gateway: None
  - Block private networks and loopback addresses: Uncheck
  - Block bogo networks: Uncheck
 
* Configure LAN3 to the vlan that Varian servers are on (vlan 112 for GRRCC)

  pfSense --> Interfaces --> LAN3

  - Enable Interface
  - IPv4 Configuration Type: Static IPv4
  - IPv4 Address: xxx.xxx.112.1/22
  - IPv4 Upstream gateway: None
  - Block private networks and loopback addresses: Uncheck
  - Block bogo networks: Uncheck

* Setup vLan ID

  pfSense --> Assignments --> VLANs

  - Parent Interface: igc0(lan) and/or igc2(opt5) 
  - VLAN Tag: 96 and/or 112
  - VLAN Priority: default
  - Description: MICAP VLAN and/or SERVER VLAN

* Configure firewall to allow LAN1 and LAN2 accessing each other

  pfSense --> Firewall --> Rules --> LAN

  - select both Default allow LAN to any rule for IPv4 and IPv6, copy to LAN2
  - Add a new rule
    * Action: Pass
    * Interface: LAN
    * Address Family: IPv4+IPv6
    * Protocol: Any
    * Source: Any
    * Destination: Any
    * Description: No In/Out restriction for LAN
   
  pfSense --> Firewall --> Rules --> LAN3

  - Add a new rule
 
    * Action: Pass
    * Interface: LAN3
    * Address Family: IPv4+IPv6
    * Protocol: Any
    * Source: Any
    * Destination: LAN subnets
    * Description: No In/Out restriction for LAN3

  _Note:_
  * _the above configuration should work well for vlan 96 and 112 to access each other._
  * _by default pfSense will route between all interfaces assigned and setup, but the firewall rules will block it by default._

## 3. Connections for DICOM RT Mode Treatment

![image](images/Tx%20Network%20Layout.png)

_Note:_
* _if a switch is used for routing between vLANs, a multi-layer (layer 3) switch must be used._
* _a router can be used, such as a pfSense firewall router as configured in step 2._
* _make sure the network cable from Juniper connect directly to the emergency treatment system_

