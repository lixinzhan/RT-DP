<h3>PACS Setup</h3>

* __podman__
  
  ```
  sudo dnf install podman podman-compose podman-docker podman-tui
  mkdir -p /opt/orthanc/etc
  cd /opt
  vi docker-compose.yml
  podman-compose up -d
  podman ps
  ```

  _Note: container is up but not accessible through web. Try vanilla docker_

* __Docker CE__

  ```
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install docker-ce
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo dnf install docker-compose-plugin
  sudo docker compose up -d
  ```

  _Note:_ 
    * _RT-EMR PACS based on Docker CE is running with no problem, but cannot query from other modalities yet._ **Other modality should have RTEMR node added to accept queries**
    * _See [this link](https://help.hcltechsw.com/bigfix/10.0/mcm/MCM/Install/install_docker_ce_docker_compose_on_rhel_8.html) for possible firewall issue._
    * _There is possible network conflict when using docker based Orthanc. It is suggested to set up orthanc in a seperate server._

* __[Firewall Setup](https://help.hcltechsw.com/bigfix/10.0/mcm/MCM/Install/install_docker_ce_docker_compose_on_rhel_8.html)__

  - Check which interface Docker is using. For example, 'docker0'.

    ```
    ip link show
    ```
  - Check available firewalld zones. For example, 'public'

    ```
    sudo firewall-cmd --get-active-zones
    ```
  
  - Check which zone the Docker interface is bound to. Typically, the Docker interface is not bound to a zone yet.

    ```
    sudo firewall-cmd --get-zone-of-interface=docker0
    ```
  
  - Add the 'docker0' interface to the 'public' zone. Changes are visible only after the firewalld is reloaded

    ```
    sudo nmcli connection modify docker0 connection.zone public
    ```
  
  - Masquerading enables Docker ingress and egress.

    ```
    sudo firewall-cmd --zone=public --add-masquerade --permanent
    ```
  
  - Reload the firewalld

    ```
    sudo firewall-cmd --reload
    ```

  - Save firewall config
 
    ```
    sudo firewall-cmd --runtime-to-permanent
    ```
    
  - Restart dockerd

    ```
    sudo systemctl restart docker
    ```

  _Note: See [this link](https://github.com/lixinzhan/GRRCC_IT/blob/main/Linux/INSTALL_RHEL.md) for more firewall setup information._
