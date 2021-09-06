#!/bin/bash

echo "FYI some extras to remember on login for your personal security"
echo "* set root password : sudo passwd root"
echo "* change disk password (currently cypher) with : sudo cryptsetup luksChangeKey /dev/sda2 -S 0"

sudo pacman -S openssh --noconfirm
sudo systemctl start sshd
#sudo systemctl status sshd

sudo echo "lets go tangram setup"
bash <(curl -sSL https://tangrams.io/install.sh)
bash <(curl -sSL https://tangrams.io/bamboo/install.sh)


