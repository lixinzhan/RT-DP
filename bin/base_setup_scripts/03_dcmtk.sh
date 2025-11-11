#!/bin/bash
#

source ../env.dcmtk

sudo apt-get update && sudo apt-get install -y dcmtk
sudo ufw allow from ${REMOTE_IP} to any port ${LOCAL_PORT}
sudo ufw status verbose
sudo ufw reload

