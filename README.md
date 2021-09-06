# loxxon

Experimental script that installs Arch Linux on an Auto-encrypted LUKS LVM . It will wipe out all the data in the selected drive, so use at your own risk. We recommended you use : \ Oracle virtualbox for the usb passthrough accuracy (setup in docs folder ) \ solokey will be an optional extra added later to simplify the login decryption

Not Tested on AMD

## Usage
To install arch on an intel Virtual Machine
Just run:
```
bash <(curl -sSL https://raw.githubusercontent.com/blocbit/loxxon/main/archS.sh)
```
or for advanced users that wish to change their LUKS secret add parameters in the following order( disk path, cpu type, LUKS secret) .NB. all or none
```
bash <(curl -sSL https://raw.githubusercontent.com/blocbit/loxxon/main/archS.sh) /dev/sda intel n3ws3cr3t
```

## Explanation
I just make the whole /run accessible to the chroot jail, because grub-mkconfig needs access to /run/lvm and /run/udev to run properly when Arch Linux is installed on LVM.
```
mkdir /mnt/hostrun
mount --bind /run /mnt/hostrun
arch-chroot /mnt
mount --bind /hostrun /run
```
a startup script has been added for the open beta to update the cypher node and wallet on every login

## Players

https://www.virtualbox.org/wiki/Downloads \
https://archlinux.org/download/ \
https://solokeys.com/ or https://www.yubico.com/ \
https://tangrams.io/