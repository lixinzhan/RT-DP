#!/bin/bash
#

# For sqlcmd: MS SQL commandline tool
#
OSVER=`cat /etc/os-release | grep VERSION_ID | awk -F\" '{print $2}'`
#curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
#curl https://packages.microsoft.com/config/ubuntu/${OSVER}/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
curl -sSL -O https://packages.microsoft.com/config/ubuntu/${OSVER}/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update && sudo apt-get install -y mssql-tools18 unixodbc-dev

echo
echo "*** Remember to add sqlcmd/bcp executible to PATH ***"
echo "  echo 'export PATH=\"\$PATH:/opt/mssql-tools18/bin\"' >> ~/.bashrc"
echo "  source ~/.bashrc"
echo

