<h3>Base OS Installation -- Alma 9.3</h3>

* Timezone: Toronto
* Lock root account
* User: lzhan/Q5; make admin
* Minimal Install
* Security Profile: CIS AlmaLinux OS 9 Benchmark for Level 2 - Workstation
* Custom storage configuration

|Mount Point| Size | Comment |
| :--- | :--- | :--- |
| /    | 10 GiB | |
| /boot | 1024 MiB | |
| /boot/efi | 600 MiB| max and default |
| /tmp  | 5 GiB | |
| /var  | 5 GiB | |
| /var/log | 5 GiB ||
| /var/log/audit | 5 GiB ||
| /var/tmp | 5 GiB ||
| /dev/shm | 5 GiB ||
| /home | 30+ GiB ||
| /opt | 30+ GiB | optional |
| swap | 16 GiB | 3xRAM (<2GB); 2x (2-8GB); 1.5x (8-64G); no hibernation (>64GB) |

* Reset Secure login 5@LtQ%<Secure>
* Setup network: `nmtui` --- GRCC6082:###.###.96.220/24


------------------------------------------------------------------------------------------------

<h3>Further Configuration</h3>

* Enable EPEL and CRB

```
sudo dnf install epel-release
sudo dnf install dnf-plugins-core
sudo dnf config-manager --set-enabled crb                   # for Alma/Rocky 9
sudo dnf repolist
sudo dnf check-update
sudo dnf update
```

* Install OpenSCAP

```
sudo dnf install openscap
sudo dnf install scap-workbench
```

* Install XFCE

```
sudo dnf group list
sudo dnf groupinstall "Xfce"      ## include "base-x"?
#echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
sudo systemctl set-default graphical
sudo dnf install firefox
sudo reboot
```
