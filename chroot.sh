#!/bin/sh

setup_locale() {
  echo en_US.UTF-8 UTF-8 >/etc/locale.gen
  locale-gen
  echo LANG=en_US.UTF-8 >/etc/locale.conf
  ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  echo KEYMAP=us >/etc/vconsole.conf
}

setup_clock() {
  hwclock --systohc
}

setup_host() {
  echo $1 >/etc/hostname
  printf "%-12s%-12s\n%-12s%-12s\n%-12s%-12s\n" 127.0.0.1 localhost ::1 localhost 127.0.1.1 "$1" | sed 's/[[:space:]]*$//' >/etc/hosts
}

setup_root() {
  echo "root:$1" | chpasswd
}

setup_user() {
  useradd -m -G wheel -s /bin/zsh "$1"
  echo "$1:$2" | chpasswd
}

setup_sudo() {
  sed -E -i 's/^# (%wheel ALL=\(ALL\) ALL)/\1/' /etc/sudoers
}

setup_grub() {
  device="$1"
  grub-install "$device"
  grub-mkconfig -o /boot/grub/grub.cfg
}

enable_internet() {
  systemctl enable NetworkManager
}

setup_locale
setup_clock
setup_host arch-pc
setup_root 123
setup_user arch 123
setup_sudo
setup_grub /dev/sda
enable_internet
