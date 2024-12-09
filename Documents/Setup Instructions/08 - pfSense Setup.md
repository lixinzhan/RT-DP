<h2>Steps for Setting up pfSense Firewall</h2>

* Normal installation

* System --> Advanced --> Admin Access --> **Disable DNS Rebinding Checks (ON)**

* System --> General Setup --> Hostname, Domain / DNS server Settings / Localization Timezone / 

* Interfaces --> WAN / LAN --> **Block Private networks and loopback addresses (Uncheck)**

* Interfaces --> WAN / LAN --> **Blockbogon networks (Check)**

* Services --> DNS Forwarder (Enable)

* Services --> DNS Resolver (Disable)

* Status --> Services

_Note: if pinging a computer without domain name failed, check the client's setting of "Search domains" first._

# System General Setup

System --> General Setup   for Hostname, domain, DNS servers and Timezone etc.

![image](images/System%20-%20General%20Setup.PNG)

# DNS resolving

Enable Forwarder but diable resolver for simplicity

![image](images/Service%20-%20DNS%20Forwarder.PNG)
![image](images/Service%20-%20DNS%20Resolver.PNG)


# Port Forwarding

1. Firewall --> NAT --> Add 

![image](images/Firewall%20-%20NAT.PNG)

2. Interfaces --> WAN

![image](images/Interfaces%20-%20WAN.PNG)

This is due to the fact that GRH network is in the private network range (172.16.0.0/12)

_Probably "Block Bogon Network" should be disabled too (?) But at least it is working with it on for now._ 

Firewall --> Rules   should display as below:

![image](images/Firewall%20-%20Rules%20-%20WAN.PNG)

_Notes:_
  * _Port 22 for SSH, and port 4042 for dcmtk DICOM communication._
