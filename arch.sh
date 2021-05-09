#!/bin/sh
ping -c 3 archlinux.org
timedatectl set-ntp true
timedatectl status
sgdisk -n 1:0:+500M -t 1:ef00 -c 1:boot /dev/sda
sgdisk -n 2::+4G -t 2:8200 -c 2:swap /dev/sda
sgdisk -n 3:: -t 3:8300 -c 3:root /dev/sda
sgdisk -p /dev/sda
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
pacman -Syy
pacman -S reflector
reflector --verbose -c BR -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware zsh neovim
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt

echo en_US.UTF-8 UTF-8 >/etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >/etc/locale.conf
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --
echo KEYMAP=us >/etc/vconsole.conf
PC_NAME=eliseu-pc
echo $PC_NAME >/etc/hostname
printf "%-12s%-12s\n%-12s%-12s\n%-12s%-12s\n" 127.0.0.1 localhost ::1 localhost 127.0.1.1 $PC_NAME | sed 's/[[:space:]]*$//' >/etc/hosts
passwd
USER_NAME=eliseu
useradd -m -G wheel -s /bin/zsh $USER_NAME
passwd $USER_NAME
EDITOR=nvim visudo
sed -E -i 's/^# (%wheel ALL=\(ALL\) ALL)/\1/' /etc/sudoers
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S networkmanager
systemctl enable NetworkManager
exit

reboot
