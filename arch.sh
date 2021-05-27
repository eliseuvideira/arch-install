#!/bin/sh

check_internet() {
  if ping -q -c 1 -W 1 archlinux.org >/dev/null; then
    return 0;
  fi
  return 1;
}

write_partition_table() {
  boot_size="$1"
  swap_size="$2"
  device="$3"
  printf ",$boot_size,\n,$swap_size,82\n,," | sfdisk "$device" --label dos
}

set_ext2() {
  partition="$1"
  mkfs.ext2 "$partition"
}

set_swap() {
  mkswap "$partition"
  swapon "$partition"
}

set_ext4() {
  partition="$1"
  mkfs.ext4 "$partition"
}

write_partition_table 512M 4G /dev/sda
set_ext2 /dev/sda1
set_swap /dev/sda2
set_ext4 /dev/sda3

ping -c 3 archlinux.org
timedatectl set-ntp true
timedatectl status
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
