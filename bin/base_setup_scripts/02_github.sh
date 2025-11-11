#!/bin/bash
#

#
# For github-cli  --- should be there already once this script is available.
#

sudo apt-get update && sudo apt-get install -y git gh

echo
echo *** To setup github authentication, run: ***
echo gh auth login
echo 
echo *** To clone RT-DP repository, run: ***
echo gh repo clone https://github.com/lixinzhan/RT-DP.git
echo
echo

echo *** Remember to set global preference for your git as below: ***
echo git config --global user.email "me@email.com"
echo git config --global user.name "First Last"
echo git config --global core.editor "vim"


#sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
#	sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
#	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
#	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
#	sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
#	&& sudo apt-get update \
#	&& sudo apt-get install -y gh

