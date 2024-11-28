# Helper Node Options

1. VM on windows server with shared folder (not tested)

   Requirement: Hyper-V, VMware Player, or VirtualBox.

2. *** **OpenSSH + Task Scheduler (Method used for now)** ***

   Requirement: win10 1809+ / win2019+


## OpenSSH Installation and Configuration

1. Windows 2019/2022 server installation and setup.
   * Basic vanilla installation
   * Add optional feature OpenSSH-Server
   * Apply patches
   * Join the domain


   _Notes:_
      * _Install OpenSSH before joining domain, to avoid domain limitation and make sure OpenSSH package can be found._
     
      * _Manually add OpenSSH Server Addon Feature, if not done previously:_
         * _Downloading the [Languages and Optional Features ISO](https://go.microsoft.com/fwlink/p/?linkid=2195333), or find it from [this page](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)_
         * _Mount the ISO to the Win2022 server._
         * _Install using PowerShell:_

           ```
           Add-WindowsCapability -online -name OpenSSH.Server~~~~0.0.1.0 -source D:\LanguagesAndOptionalFeatures
           ```

      * _see this link https://zomro.com/blog/faq/406-how-to-raise-openssh-on-windows-2019 for file download and 2019 setup_

2. Setup SSH and private/public keys. See [this link](https://techcommunity.microsoft.com/t5/itops-talk-blog/installing-and-configuring-openssh-on-windows-server-2019/ba-p/309540)
   * set openssh-server and openssh-agent services automatic start on the server (Windows) side 

     ```
     Start-Service sshd
     Set-Service -Name sshd -StartupType 'Automatic'
     Start-Service ssh-agent
     Set-Service -Name ssh-agent -StartupType 'Automatic'
     ```
     
   * create public and private keys

     ```
     ## For non-admin users: copy client public key to the server side
     # scp <client/linux-side-user>\.ssh\id_rsa.pub <server-side-user>@<server-hostname-or-ip>:C:\Users\<server-side-user>\.ssh\authorized_keys

     ## For users in the administrator group, copy the client key to ProgramData and set the correct pomission
     # scp <client/linux-side-user>\.ssh\id_rsa.pub <server-admin-user>@<server-hostname-or-ip>:C:\ProgramData\ssh\administrators_authorized_keys
     # icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

     ## set permission for allowed users only in C:\ProgramData\ssh\sshd_config
     # DenyUsers
     # AllowGroups
     
     ## See https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration?WT.mc_id=social-twitter-orthomas for more options
     ```

3. __user for ssh should be the same as the scheduled script running user on windows. Both should be domain account eclipse@grhosp.com for us.__

## Task Scheduling on Windows

Computer Management --> System Tools --> Task Scheduler --> Task Scheduler Library --> Create New Task

(GRRCC setup: _user account used for task running: eclipse@grhosp.com,_ and _scheduled to run every 30 min._)

![image](https://github.com/user-attachments/assets/78cc4135-d780-4b02-88a4-f1a8472827d6)

![image](https://github.com/user-attachments/assets/d07b0840-95fd-4771-b2b5-eaad9f7feb33)

![image](https://github.com/user-attachments/assets/0c5df042-fcac-424d-88a7-5e1b64ec722b)

**Note:**

1. _SSH/task running user should have write permission to both RTDR-Cache and RTDR-Data folders_
2. _RTDR-Data folder should be shared to a few physicists/therapists for frequent backup file integrity check_

# Appendix: PSRemoting over SSH (Server Hopping is not supported, hence not an option for the current project)

1. Install PowerShell 7.4.1 on Windows (dc3-br-ehelper)

   * take a snapshot
   * download and install powershell 7.4.1, all default
   * notepad.exe c:\ProgramData\ssh\sshd_config

     ```
     PasswordAuthentication yes
     PubkeyAuthentication yes
     Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs
     ```

   * `Restart-Service sshd`
  
2. Install PowerShell on Ubuntu

   * PowerShell Install
  
      ```
      sudo apt update
      sudo apt install wget apt-transport-https software-properties-common
      wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
      sudo dpkg -i packages-microsoft-prod.deb
      rm packages-microsoft-prod.deb
      sudo apt update
      sudo apt install powershell
      ```

   * Configure SSH in `/etc/ssh/sshd_config`

     ```
     PasswordAuthentication yes
     PubkeyAuthentication yes
     Subsystem powershell /usr/bin/pwsh -sshs
     ```
   * `sudo systemctl restart sshd.service`

