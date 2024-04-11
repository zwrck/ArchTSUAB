#!/bin/bash

clear

echo -ne "
████████╗███████╗██╗   ██╗ █████╗ ██████╗
╚══██╔══╝██╔════╝██║   ██║██╔══██╗██╔══██╗
   ██║   ███████╗██║   ██║███████║██████╔╝
   ██║   ╚════██║██║   ██║██╔══██║██╔══██╗
   ██║   ███████║╚██████╔╝██║  ██║██████╔╝
   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝
------------------------------------------
Arch Installation Part One
"

timedatectl set-ntp 1

iso=$(curl -4 ifconfig.co/country-iso)
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
echo "Setting up mirrors..."
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

# Table and Partitioning
echo "Partitioning..."

sgdisk -a 2048 -o /dev/sda
sgdisk -n 1::+1G --typecode=1:ef00 /dev/sda
sgdisk -n 2::0 --typecode=2:8300 /dev/sda

#sgdisk --change-name=1:'EFIBOOT' /dev/sda
#sgdisk --change-name=2:'ROOT' /dev/sda

# Formating
echo "Formating..."

mkfs.ext4 /dev/sda2
mkfs.fat -F 32 /dev/sda1

# Mounting
echo "Mounting..."

mount /dev/sda2 /mnt
mount --mkdir /dev/sda1 /mnt/boot/

# Install essential packages
echo "Installing base system..."

pacstrap -K /mnt base linux linux-firmware nano sudo --noconfirm --needed;

# Configure the system
echo "Generating fstab..."

genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

cd
truncate --size=0 /mnt/etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist >> /mnt/etc/pacman.d/mirrorlist
cp -R ArchTSUAB /mnt/home/

echo -e "Proceed with Part Two\ncd /home/ArchTSUAB\n./02-install.sh"

arch-chroot /mnt

reboot
