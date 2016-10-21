#!/bin/bash


URL_KEY_REPO=https://github.com/mozilla-services/fx-test-pubkeys
REPO=$(basename $URL_KEY_REPO)


echo
echo "-------------------------------"
echo "SET NOPASSWD IN SUDOERS"
echo "-------------------------------"
echo

if ! grep -q NOPASSWD /etc/sudoers; then
   echo "Re-writing sudoers ..."
   sed -i 's/^%sudo.*/%sudo    ALL=NOPASSWD: ALL/' /etc/sudoers
fi

# TODO: add conditional for other OS
if ! grep -q "Ubuntu" /etc/lsb-release; then
    echo "Not Ubuntu --> Aborting!"
    exit
fi

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
        echo "ADDING USER: $user"
        adduser  --disabled-password --gecos "" $user
        adduser $user sudo
        mkdir /home/$user/.ssh
        cp $key /home/$user/.ssh/authorized_keys
    else
        echo "USER: $user ALREADY EXISTS!"

    fi
done

echo
echo "DONE!"
echo
