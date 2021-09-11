#!/bin/bash

if [ -d "/opt/cypher/bamboo/" ]  
then
    echo "Do you wish to update your node and wallet?"
    select yn in "Yes" "No"
    case $yn in
       Yes ) bash <(curl -sSL https://tangrams.io/install.sh);;
       No ) echo "Shits Done";;
    esac  
else
    sudo echo "Lets go setup"
    sudo pacman -S openssh --noconfirm
    sudo systemctl start sshd
    #sudo systemctl status sshd
    bash <(curl -sSL https://tangrams.io/install.sh)
    bash <(curl -sSL https://tangrams.io/bamboo/install.sh)
    sudo mv /etc/systemd/system/appsettings.json /opt/cypher/bamboo/appsettings.json
    echo "Do you wish to install a hardware key, if you awnser NO you must change your LUKS Secrect?"
    select yn in "Yes" "No"
    case $yn in
       Yes ) sudo touch $HOME/.keysecure;;
       No ) sudo cryptsetup luksChangeKey /dev/sda2 -S 0;;
    esac
fi 

if [ -e $HOME/.keysecure ]  
then  
    sudo su
	pacman -Syu yubikey-full-disk-encryption --noconfirm
	read -p "insert you hardware key now, it will be overwritten, press any button go, (n) to skip " -n 1 -r
      ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible	  
	  ykfde-enroll -d /dev/sda2 -s 2 -o
	  cryptsetup luksChangeKey /dev/sda2 -S 0
	  mkdir /etc/Yubico/
	  su lx
	  mkdir ~/.config/
      mkdir ~/.config/Yubico/
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
      echo " key config skipped, change Luks secret "
	  cryptsetup luksChangeKey /dev/sda2 -S 0
    fi
	sudo rm -rf $HOME/.keysecure
	sudo echo "FYI some extras to remember on login for your personal security"
    sudo echo "* set root password : sudo passwd root"
else
	sudo echo "FYI some extras to remember on login for your personal security"
    sudo echo "* set root password : sudo passwd root"
fi 

sudo /opt/cypher/bamboo/dotnet clibamwallet.dll