<h2>Base OS Installation -- Xubuntu</h2>

* Timezone: Toronto
* Minimal Install
* Currently default partitioning
* Secure login <Secure>5@LtQ%<Secure>
* Setup network: `nmtui`


<h3>Add necessary packages</h3>

```
sudo apt update
sudo apt upgrade
sudo apt install openssh-server
sudo apt install vim
sudo apt install curl
```

------------------------------------------------------------------------------------------------

## Appendix

<h3>Add second drive</h3>

```
sudo lshw -C disk
lsblk
sudo apt install xfsprogs
sudo mkfs.xfs -b size=4096 -m reflink=1,crc=1 /dev/sdb -f
sudo blkid /dev/sdb
```

Add below to `/etc/fstab` for automount when booting `vi /etc/fstab`

```
/dev/disk/by-uuid/<UUID from blkid>  /opt  xfs  _netdev  0  0
```

<h3>Add new user and make it sudo</h3>

```
$ sudo adduser username
$ sudo usermod -aG sudo username
```

**Allow sudo execute a command, e.g. /usr/sbin/ip, without password**

```
# use command below to edit the /etc/sudoer.
# remember to open another window with 'sudo -i' runnning first, in case a misconfiguration locking sudo out.
sudo visudo
```

And add the line below to /etc/sudoer

```
username    ALL=(ALL) NOPASSWD:/usr/sbin/ip
```


<h3>CRON job scheduling</h3>

To schedule a cron job to such as 19:30, use root account or an user listed in `/etc/cron.allow`

```
crontab -e

30 19 * * * ${RTEMRPATH}/bin/query_aria.sh
```

<h3>Create ALTNAME for NIC</h3>

```
ip link property add dev ens33 altname eth0
```

_Note:_ 

* _This altname is temporary. It disappears after reboot._

* _For more information about NIC naming scheme, see [this link](https://systemd.io/PREDICTABLE_INTERFACE_NAMES/)_

* _As talked [here](https://www.reddit.com/r/Fedora/comments/qlqo7u/persistent_altname_for_an_interface/), it seems `bootloader --append="net.ifnames=0"` is the most reliable option for persistence name change._
  
