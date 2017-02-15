#!/bin/bash


URL_KEY_REPO=https://github.com/mozilla-services/fx-test-pubkeys
REPO=$(basename $URL_KEY_REPO)


echo
echo "--------------------------------"
echo "INSTALL ADD-USER INIT SCRIPT"
echo "--------------------------------"
echo
cd $HOME 
mkdir utils
cd utils
git clone $URL_KEY_REPO
cd $HOME/$REPO
sudo su
cd /etc/systemd/system/multi-user.target.wants
ln -s /home/ubuntu/utils/$REPO/add_users.service .

echo
echo "--------------------------------"
echo "ADDING USERS"
echo "--------------------------------"
echo
add-user.sh
echo 
echo "DONE!"
