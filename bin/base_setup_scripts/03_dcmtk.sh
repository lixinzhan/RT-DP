#!/bin/bash
#

#source ../env.dcmtk
REMOTE_IP="172.17.115.102"
LOCAL_PORT="4042"

sudo apt-get update && sudo apt-get install -y dcmtk
sudo ufw allow from ${REMOTE_IP} to any port ${LOCAL_PORT}
sudo ufw status verbose
sudo ufw reload

