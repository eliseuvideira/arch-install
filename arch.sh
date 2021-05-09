#!/bin/sh
SWAP_SIZE="$1"

ping -c 3 archlinux.org
timedatectl set-ntp true
timedatectl status
sgdisk -n 1:0:+500M -t 1:ef00 -c 1:boot /dev/sda
sgdisk -n 2::+"$SWAP_SIZE" -t 2:8200 -c 2:swap /dev/sda
sgdisk -n 3:: -t 3:8300 -c 3:root /dev/sda
sgdisk -p /dev/sda
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base base-devel linux linux-firmware zsh neovim
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt
