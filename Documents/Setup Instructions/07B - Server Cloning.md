# Varian Server Cloning for File Mode Treatment

Since TrueBeam 4.x, VSP is required even for file mode treatment. Hence we need to clone at least the **VSP** server for offline login. To make things simplified, the **VA_TRANSFER** server will be cloned at the same time.

## Clinical System is running under vSphere

1. Setup a standalone ESXi server
   - Server IP should be out of both Linac and Server VLAN
   - Configure firewall router (pfSense here), with WAN on the ESXi server VLAN
   - WAN should be disconnected if not in use
   - Two LAN for Linac and Servers, with firewall fully open between them.
     
