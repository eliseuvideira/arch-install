#!/bin/sh

has_internet() {
  if ping -q -c 1 -W 1 archlinux.org >/dev/null; then
    return 0;
  fi
  return 1;
}

setup_date() {
  timedatectl set-ntp true
}

write_partition_table() {
  boot_size="$1"
  swap_size="$2"
  device="$3"
  wipefs -a "${device}*"
  printf ",$boot_size,\n,$swap_size,82\n,," | sfdisk "$device" --label dos
}

set_ext2() {
  mkfs.ext2 "$1"
}

set_swap() {
  mkswap "$1"
  swapon "$1"
}

set_ext4() {
  mkfs.ext4 "$1"
}

mount_partitions() {
  boot_partition="$1"
  root_partition="$2"
  mount_point="$3"
  mkdir -p "$3"
  mount "$root_partition" "$mount_point"
  mkdir /mnt/arch/boot
  mount "$boot_partition" "${mount_point}/boot"
}

get_packages() {
  cat <<EOF
base
base-devel
linux
linux-firmware
zsh
neovim
networkmanager
grub
git
EOF
}

if ! has_internet; then
  echo "no internet available"
  exit 1
fi

setup_date

write_partition_table 512M 4G /dev/sda

set_ext2 /dev/sda1
set_swap /dev/sda2
set_ext4 /dev/sda3

mount_partitions /dev/sda1 /dev/sda3 /mnt/arch

pacstrap /mnt/arch $(get_packages)

genfstab -U /mnt/arch >>/mnt/arch/etc/fstab

echo "arch-chroot /mnt/arch"
