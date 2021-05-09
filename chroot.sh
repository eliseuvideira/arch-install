#!/bin/sh
LOCALE_ZONE="$1"
PC_NAME="$2"
USER_NAME="$3"

echo en_US.UTF-8 UTF-8 >/etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
ln -s "/usr/share/zoneinfo/$LOCALE_ZONE" /etc/localtime
hwclock --systohc
echo KEYMAP=us >/etc/vconsole.conf
echo $PC_NAME >/etc/hostname
printf "%-12s%-12s\n%-12s%-12s\n%-12s%-12s\n" 127.0.0.1 localhost ::1 localhost 127.0.1.1 $PC_NAME | sed 's/[[:space:]]*$//' >/etc/hosts
passwd
useradd -m -G wheel -s /bin/zsh $USER_NAME
passwd $USER_NAME
sed -E -i 's/^# (%wheel ALL=\(ALL\) ALL)/\1/' /etc/sudoers
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S networkmanager
systemctl enable NetworkManager
