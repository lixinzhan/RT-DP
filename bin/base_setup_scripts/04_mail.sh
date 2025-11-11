#!/bin/bash
#

source ../env.email

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

