#!/bin/bash
#

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y openssh-server vim curl xfsprogs

sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw status verbose
sudo ufw reload
