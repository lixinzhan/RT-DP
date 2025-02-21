#!/bin/bash
#

FROMMAIL="GRC.RT-DP@grhosp.on.ca"
ADMINMAIL="lixin.zhan@grhosp.on.ca"

echo "Status for service postfix on host $(hostname):" > /tmp/testemail.txt
echo >> /tmp/testemail.txt
sudo systemctl status postfix | grep Active >> /tmp/testemail.txt

echo >> /tmp/testemail.txt
echo "=============================================" >> /tmp/testemail.txt
echo >> /tmp/testemail.txt

echo "*** Configurations ***" >> /tmp/testemail.txt
echo >> /tmp/testemail.txt

echo "Settings in /etc/mailname:" >> /tmp/testemail.txt
echo >> /tmp/testemail.txt
cat /etc/mailname >> /tmp/testemail.txt
echo >> /tmp/testemail.txt

echo "Settings in /etc/postfix/main.cf: " >> /tmp/testemail.txt
echo >> /tmp/testemail.txt
cat /etc/postfix/main.cf | grep "^relayhost" >> /tmp/testemail.txt
cat /etc/postfix/main.cf | grep "^myhostname" >> /tmp/testemail.txt
cat /etc/postfix/main.cf | grep "^mydestination" >> /tmp/testemail.txt

cat /tmp/testemail.txt | mail -s "RT-DP test email from $(hostname)" \
	-aFrom:"${FROMMAIL}" \
	-aReply-to:"${ADMINMAIL}" \
	${ADMINMAIL}

