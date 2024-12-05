<h3>System Hardening</h3>

1. Launch `scap-workbench`
2. Scan --- with Download Remote Resources and Remediate checked (__Auto Remediation__)

    Results: 6 rules not satisfied! (__To be Manually Remediated__)

    - Ensure the Group Used by pam_wheel Module Exists on System and is Empty
        
        _Since root login disabled, sudoer has to exist._ 
        
        __No further steps will be taken here.__

    - Ensure Authentication Required for Single User Mode

        _For rescue more authentication. Keep it as is for now._

    - Enforce Usage of pam_wheel with Group Parameter for su Authentication
        _To ensure only users of pam_wheel can run commands with su command._ _Make sure `/etc/pam.d/su` contains: `auth required pam_wheel.so use_uid group=sugroup`_ 
        
        __Not set for now before further investigation.__

    - Set Default firewalld Zone for incoming Packets

        _By default, DefaultZone=public. This is asking to set DefaultZone=drop._ 
        
        __To be worked on after further study.__
        
    - Ensure No Daemons are Unconfined by SELinux

        _To check for unconfined daemons, run `sudo ps -eZ | grep "unconfined_service_t" ` with no output ideally._ _Remediation can be achieved by amending SELinux policy or stopping the unconfined daemons._ 
        
        __Nothing will be worked on for this for now__

    - Limut Users' SSH Access

        _It is recommended at least one of the following options be leveraged: AllowUsers/AllowGroups/DenyUsers/DenyGroups._ 
        
        __First test by enabling AllowUsers was not working for this issues. Further tests to be worked on__


