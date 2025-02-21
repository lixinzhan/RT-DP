<h2>Setup Steps for Radiation Therapy Disaster Preparedness (RT-DP) System</h2>

Steps for setting up RT-DP. Instructions included in this folder may contains information more than required.
The current setup procedure is based on Ubuntu and tested on 22.04 and 24.04. It should work for all Debian based OS.
Script `${RT-DP}/bin/base_setup.sh` should be run first for github(02)/sqlcmd(03)/gpg(04)/dcmtk(05)/postfix(doc to be added) setup on the data retrieval server.

### Basic Setup Steps

1. [Install the base OS](./01%20-%20OS%20Installation%20-%20Ubuntu.md)

2. [GitHub setup](./02%20-%20GitHub%20Setup.md) and RT-DP repo download

    ```
    cd /opt && sudo mkdir RT-DP && sudo chown -R <username>:<group> RT-DP
    sudo apt install gh
    gh auth login
    gh repo clone https://github.com/lixinzhan/RT-DP.git
    ```

3. Edit [`bin/env.email`](../../bin/env.email) to update the POSTFIX settings and email addresses

4. Run [`bin/base_setup.sh`](../../bin/base_setup.sh), which works on

    - DCMTK installation
    - github-cli installation (Step 2 might have installed github-cli comes with the OS. This is to make sure the latest version installed)
    - [MS SQL command line tools (mssql-tools18) installation](./03%20-%20MS%20SQL%20Command-Line%20Tools.md)
    - POSTFIX/mailutils installation and setup, which uses settings in [`bin/env.email`](../../bin/env.email)

5. Update environment configurations too meet clinical settings:

    - [`bin/env.sql`](../../bin/env.sql): **DBSVR**
    - [`bin/env.dcmtk`](../../bin/env.dcmtk): **LOCAL_AET, LOCAL_PORT, REMOTE_AET, REMOTE_IP, REMOTE_PORT**
    - [`bin/env.network`](../../bin/env.network): **MYNIC**
    - [`bin/env.ehelper`](../../bin/env.ehelper): **Image server nfo and ehelper info**

6. [Setup account info for script authentication](./04%20-%20GPG%20Encryption%20Setup.md)

    _Note: GPG encrypted password file should be in `Keys` folder_

7. [Setup the helper node](./06%20-%20Helper%20Node%20Setup.md)

8. Test the system

    ```
    cd /opt/RT-DP/bin && ./main_run.sh
    ```

9. Setup cron job for scheduled RT-DP data retrieval

    ```
    crontab -e

    30 19 * * * ${RTDPPATH}/bin/main_run.sh
    ```

10. When all the above is working as expected, [setup pfSense firewall](08%20-%20pfSense%20Setup.md) and isolate the system behind the firewall
---------------------------------

11. Further hardening can be applied:

    - ufw
    - fail2ban
    
