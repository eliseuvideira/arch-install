#!/bin/sh
ping -c 3 archlinux.org
timedatectl set-ntp true
timedatectl status
sgdisk -n 1:0:+512MiB  -t 1:ef00  -c 1:efi   /dev/sda
sgdisk -n 2::+256MiB   -t 2:8300  -c 2:boot  /dev/sda
sgdisk -n 3::+4GiB     -t 3:8200  -c 3:swap  /dev/sda
sgdisk -n 4::          -t 4:8300  -c 4:root  /dev/sda
sgdisk -p /dev/sda
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sd2
mkswap /dev/sda3
swapon /dev/sda3
mkfs.ext4 /dev/sda4
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base base-devel linux linux-firmware zsh neovim
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt
