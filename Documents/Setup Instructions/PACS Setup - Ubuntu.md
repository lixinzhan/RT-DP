<h2>PACS Setup - Orthanc in Docker</h2>

* __Docker__

  ```
  sudo apt install docker-io
  sudo apt install docker-compose-v2
  # sudo systemctl start docker
  # sudo systemctl enable docker
  sudo systemctl status docker
  sudo docker compose up -d
  sudo docker ps
  sudo docker images
  ```

  _Note: Both Ubuntu package Docker.io and official reposiroty Docker-CE can be used. We choose Docker.io for simplifying the setup steps and keeping system stable._

* __Orthanc__

  
  - generate a docker compose file for Orthanc, [docker-compose.yml](https://github.com/lixinzhan/RT-EMR/blob/main/Setup%20Steps%20for%20Emergency%20Rescue/orthanc/docker-compose.yml)
  - generate an Orthanc configuration file, [orthanc.json](https://github.com/lixinzhan/RT-EMR/blob/main/Setup%20Steps%20for%20Emergency%20Rescue/orthanc/etc/orthanc.json)
  - AET: RTEMR_DV; IP: 172.17.115.142; PORT: 4242
  - make sure other DICOM modalities have this node added in
  - bring up the Orthanc docker: `sudo docker compose up -d`
 
  _Note:
  	* [Orthanc Docker ](https://hub.docker.com/r/jodogne/orthanc/tags) being chosen instead of the Ubuntu package is to keep Orthanc up-to-date._

	* _There is possible network conflict when using docker based Orthanc. It is suggested to set up orthanc on a seperate server._


<h3>Configure Other Modalities for Access from Orthanc RTEMR</h3>

- Other Orthanc modalities
  
  Add entry to "DicomModalities" session in orthanc.json: `"RTEMR_DV" : [ "RTEMR_DV", "172.17.115.142", 4242 ], `

- Varian ARIA DB Access (dc3-va-dcm --> DICOM Services Configuration --> **VMSDBD**)

  ![image](https://github.com/lixinzhan/RT-EMR/assets/6154401/78a1fa6f-520f-4ada-8b94-20526df41590)

- Velocity (Settings --> Location)

  ![image](https://github.com/lixinzhan/RT-EMR/assets/6154401/8f65ef4d-f115-450a-b140-35f495cf74dc)

