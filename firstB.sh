#!/bin/bash

sudo pacman -S openssh --noconfirm

sudo echo "lets go tangram setup"
bash <(curl -sSL https://tangrams.io/install.sh)
bash <(curl -sSL https://tangrams.io/bamboo/install.sh)


echo "FYI some extras to remember on login for your personal security"
echo "* set root password : sudo passwd root"
echo "* change disk password (default: cyph3r) with : sudo cryptsetup luksChangeKey /dev/sda2 -S 0"
echo "* start ssh with : sudo systemctl start sshd"