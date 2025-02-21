#!/bin/bash
#

#
# Ubuntu based. Execute this OS setup script as root/sudo
#

#
# Parameters for site dependent setup
#
source ./env.email

#
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y openssh-server vim curl xfsprogs
sudo apt-get install -y dcmtk

#
# For github-cli
#
sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
	sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
	sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt-get update \
	&& sudo apt-get install -y gh

#
# For sqlcmd: MS SQL commandline tool
#
OSVER=`cat /etc/os-release | grep VERSION_ID | awk -F\" '{print $2}'`
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null
curl https://packages.microsoft.com/config/ubuntu/${OSVER}/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update && sudo apt-get install -y mssql-tools18 unixodbc-dev

echo
echo "*** Remember to add sqlcmd/bcp executible to PATH ***"
echo "  echo 'export PATH=\"\$PATH:/opt/mssql-tools18/bin\"' >> ~/.bashrc"
echo "  source ~/.bashrc"
echo

# # PowerShell installation
# sudo apt-get install -y wget apt-transport-https software-properties-common
# wget https://packages.microsoft.com/config/ubuntu/${OSVER}/packages-microsoft-prod.deb
# sudo dpkg -i packages-microsoft-prod.deb
# rm packages-microsoft-prod.deb
# sudo apt-get update && sudo apt-get install -y powershell

#
# For postfix/mailutils
# 
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet with smarthost'" 
sudo debconf-set-selections <<< "postfix postfix/mailname string ${MAILNAME}" 
sudo debconf-set-selections <<< "postfix postfix/relayhost string ${RELAYHOST}" 
sudo apt-get install -y mailutils
sudo sed -i "s:mydestination.*:mydestination = \$myhostname, localhost.localdomain, localhost:g" /etc/postfix/main.cf
sudo systemctl reload postfix

echo
echo "*** mailutils/postfix can be re-configured if necessary ***"
echo
echo "  * command: "
echo "      sudo dpkg-reconfigure postfix "
echo
echo "  * manually:"
echo "      sudo vi /etc/postfix/main.cf"
echo "      sudo vi /etc/mailname"
echo "      sudo systemctl reload postfix"
echo

echo "Congratulations! Your setup works with parameters: mailname ${MAILNAME} and relayhost ${RELAYHOST}" | \
	mail -s "RT-DP test email from $(hostname)" \
	-aFrom:"${FROMMAIL}" \
	-aReply-to:"${ADMINMAIL}" \
	${ADMINMAIL}

