#!/bin/bash


URL_KEY_REPO=https://github.com/mozilla-services/fx-test-pubkeys
REPO=$(basename $URL_KEY_REPO)
OS="UNKNOWN"

function os_dist() {
    if grep -q "Ubuntu" /etc/lsb-release 2> /dev/null; then
        OS="Ubuntu"
    elif grep -q "CentOS" /etc/os-release 2> /dev/null; then
        OS="CentOS"
    elif grep -q "CoreOS" /etc/os-release 2> /dev/null; then
        OS="CoreOS"
    else
        echo "ERROR: OS not recognized --> ABORTING!!"
        exit 1
    fi
    echo "OS: $OS detected"
}

function adduser_ubuntu() {
    adduser  --disabled-password --gecos "" $1
    adduser $1 sudo
}

function adduser_centos() {
    adduser $1 
    passwd -d $1 
    usermod -aG wheel $1 
}

function adduser_coreos() {
    sudo useradd -p "*" -U -m $1 -G sudo
}

function adduser_dist() {
   if [[ "$OS" == "Ubuntu" ]]; then
       adduser_ubuntu $1
   elif [[ "$OS" == "CentOS" ]]; then
       adduser_centos $1 
   elif [[ "$OS" == "CoreOS" ]]; then
       adduser_coreos $1 
   else
       exit 1
   fi
}


echo
echo "-------------------------------"
echo "DETERMINE OS"
echo "-------------------------------"
echo
os_dist

echo
echo "-------------------------------"
echo "SET NOPASSWD IN SUDOERS"
echo "-------------------------------"
echo

if ! grep -q NOPASSWD /etc/sudoers; then
   echo "Re-writing sudoers ..."
   sed -i 's/^%sudo.*/%sudo    ALL=NOPASSWD: ALL/' /etc/sudoers
fi
echo
echo "DONE!"
echo

echo
echo "-------------------------------"
echo "GET PUBKEY REPO"
echo "-------------------------------"
echo

rm -rf $REPO
git clone $URL_KEY_REPO
cd $REPO

echo
echo "-------------------------------"
echo "CREATING USERS"
echo "-------------------------------"
echo

for key in *.pub; do
    user=$(basename $key .pub)
    if [[ ! -d "/home/$user" ]]; then
        echo
        echo "ADDING USER: $user"
        adduser_dist $user
        mkdir /home/$user/.ssh
        cp $key /home/$user/.ssh/authorized_keys
        chown -R $user:$user /home/$user/.ssh 
    else
        echo "USER: $user ALREADY EXISTS!"
    fi
done

echo
echo "DONE!"
echo
