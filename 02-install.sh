#!/bin/bash

echo -ne "
████████╗███████╗██╗   ██╗ █████╗ ██████╗
╚══██╔══╝██╔════╝██║   ██║██╔══██╗██╔══██╗
   ██║   ███████╗██║   ██║███████║██████╔╝
   ██║   ╚════██║██║   ██║██╔══██║██╔══██╗
   ██║   ███████║╚██████╔╝██║  ██║██████╔╝
   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝
------------------------------------------
Arch Installation Part Two

Setting up locales
"

echo "Enter your Region and City"
read region city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc

# Generating locales

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo LANG=ru_RU.UTF-8 >> /etc/locale.conf

# Setting hostname & username

echo -n "Create hostname:"
read input
echo $input >> /etc/hostname
echo -n "hostname: "; cat /etc/hostname
echo -n "Create root password: "
passwd
echo -n "Create username:"
read input
useradd -m -G wheel $input
echo -ne "username: $input\n";
echo "Create $input password:"
passwd $input

# Sudoers

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Installing microcode
echo "Installing microcode"

proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
fi

# Systemd-boot
echo "Setting up Systemd-boot"

bootctl install

truncate --size=0 /boot/loader/loader.conf
echo -e "default\t\tarch.conf\ntimeout\t\t0\nconsole-mode\tmax\neditor\t\tno" >> /boot/loader/loader.conf
echo -e "title\tLinux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=dev/sda2 rw quiet" >> /boot/loader/entries/arch.conf

# Networking
echo "Installing NetworkManager"

pacman -S --noconfirm --needed networkmanager git
systemctl enable NetworkManager

# Rebooting
echo "Rebooting in 3 Seconds ..." && sleep 1
echo "Rebooting in 2 Seconds ..." && sleep 1
echo "Rebooting in 1 Second ..." && sleep 1

exit
reboot
