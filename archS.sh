#!/bin/bash
set -e
set -u

#cat > /etc/pacman.d/mirrorlist <<"EOF"
#Server = http://ftp.rediris.es/mirror/archlinux/$repo/os/$arch
#Server = http://osl.ugr.es/archlinux/$repo/os/$arch
#Server = http://archlinux.de-labrusse.fr/$repo/os/$arch
#Server = http://archlinux.vi-di.fr/$repo/os/$arch
#Server = https://archlinux.vi-di.fr/$repo/os/$arch
#EOF

#pacman -Syy reflector --noconfirm
#reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

target_device=${1:-/dev/sda}
target_core=${2:-intel}
device_secret=${3:-cyp3r}

timedatectl set-ntp true

# Do not put blank lines until EOF (unless you know what you are doing), because they will be interpreted as a <CR> inside fdisk
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${target_device}
  o # create a DOS partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +200M # 100 MB boot parttion
  t # change partition type
  ef # type EFI
  n # new partition
  p # primary partition
  2 # partition number 2
    # default - start next to the partiton1
    # default - until the end of the disk
  t # change partition type
  2 # select partition 2
  8e # type Linux LVM
  w # write the partition table
  q # and we're done
EOF

echo -n ${device_secret} | cryptsetup luksFormat -q ${target_device}2 - # default passphrase, will be changed on login

echo -n ${device_secret} | cryptsetup open ${target_device}2 lxlvm -

boot_partition=${target_device}1
lvm_partition=/dev/mapper/lxlvm

pvcreate ${lvm_partition}
pv_path=${lvm_partition}

vg_name=vg1

vgcreate ${vg_name} ${pv_path}
vg_path=/dev/${vg_name}

lv_swap_name=lv_swap
lv_root_name=lv_root

lvcreate -L 2G ${vg_name} -n ${lv_swap_name}
lvcreate -l 100%FREE ${vg_name} -n ${lv_root_name}

lv_swap_path=${vg_path}/lv_swap
lv_root_path=${vg_path}/lv_root

mkfs.fat -F32 ${boot_partition}
mkfs.ext4 ${lv_root_path}
mkswap ${lv_swap_path}
swapon ${lv_swap_path}

mount ${lv_root_path} /mnt
mkdir /mnt/boot
mount ${boot_partition} /mnt/boot

pacstrap /mnt base linux linux-firmware nano ${target_core}-ucode lvm2 grub efibootmgr networkmanager network-manager-applet mtools dosfstools base-devel linux-headers git xdg-utils xdg-user-dirs

mkdir /mnt/hostrun
mount --bind /run /mnt/hostrun

arch-chroot /mnt <<EOF
echo "lxvm " > /etc/hostname
echo "127.0.0.1    localhost
::1          localhost
127.0.1.1    lxvm.local lxvm " > /etc/hosts
mount --bind /hostrun /run
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB 
sed -i "s/GRUB_CMDLINE_LINUX=\"\"//g" /etc/default/grub
echo GRUB_CMDLINE_LINUX="cryptdevice=UUID=$(blkid -t TYPE=crypto_LUKS -s UUID -o value):lxlvm root=/dev/vg1/lv_root" >> /run/GUUID
cat /run/GUUID >> /etc/default/grub
git clone https://github.com/blocbit/loxxon.org.git /run/lx
mv /run/lx/firstB.sh /etc/profile.d/ 
grub-mkconfig -o /boot/grub/grub.cfg
umount /run
systemctl enable NetworkManager
useradd -m -p saUWZzv60AeJ. lx
usermod --append --groups wheel lx
sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers
exit
EOF

umount /mnt/hostrun
rmdir /mnt/hostrun
genfstab -U /mnt >> /mnt/etc/fstab
umount /mnt/boot
umount /mnt

echo "###NB###NB###NB###NB###"
echo "* default disk password if not set : cyph3r ( small letters )"
echo "* user account : lx ( small letter l small letter x )"
echo "* first time user password : lx ( letter l letter x )"
echo "* ready to go type : reboot"

