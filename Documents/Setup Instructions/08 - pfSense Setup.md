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

![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/69d82dd7-753e-423a-8beb-f565e3e4d845)

# DNS resolving

Enable Forwarder but diable resolver for simplicity

![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/38346a65-748f-4c50-98e4-b0aafcc240e6)
![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/ca6847c2-108e-4f88-8410-550e753d7449)


# Port Forwarding

1. Firewall --> NAT --> Add 

![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/db6f85c7-e931-4b9b-8416-01dd4700ec41)

2. Interfaces --> WAN

![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/82df4784-7f58-4285-9e44-ed3f1562e5f3)

This is due to the fact that GRH network is in the private network range (172.16.0.0/12)

_Probably "Block Bogon Network" should be disabled too (?) But at least it is working with it on for now._ 

Firewall --> Rules   should display as below:

![image](https://github.com/lixinzhan/RT-DRm/assets/6154401/60e744ff-31e4-4d6d-9f21-871f9c3b05a3)

_Notes:_
  * _Port 22 for SSH, and port 4042 for dcmtk DICOM communication._
