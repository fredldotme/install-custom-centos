# Reinstall package managers and install base packages
yum install -y hostname
yum --releasever=8 install -y yum centos-release
yum install -y redhat-lsb-core dracut-tools dracut-squash dracut-network dracut-config-rescue dracut-config-generic # is dracut-squash, dracut-network, and dracut-config-generic necessary?

# Install GRUB
yum install -y grub2 grub2-efi-x64 shim efibootmgr 

# Install kernel 
# For some reason this needs to be installed after grub
yum install -y kernel

# Configure GRUB
cat > /etc/default/grub << EOF
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.auto consoleblank=0"
GRUB_DISABLE_RECOVERY="true"
EOF

efibootmgr -c -p 1 -d $DRIVE -L "Minimal CentOS 8" -l "\EFI\centos\shimx64.efi"
grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

# Networking
yum install -y NetworkManager
cat > "/etc/sysconfig/network" << EOF
NETWORKING=yes
NETWORKING_IPV6=no
EOF

# Journald


# Something something autorelabel
touch /.autorelabel

# Fstab (see `blkid`)
EFI_UUID=$(blkid | grep "${DRIVE}1" | sed 's/^.*UUID="\(.*\)" T.*$/\1/')
BOOT_UUID=$(blkid | grep "${DRIVE}2" | sed 's/^.*UUID="\(.*\)" T.*$/\1/')
ROOT_UUID=$(blkid | grep "${DRIVE}3" | sed 's/^.*UUID="\(.*\)" T.*$/\1/')

cat > /etc/fstab << EOF
UUID=$EFI_UUID	/boot/efi	vfat	defaults	0	0
UUID=$BOOT_UUID	/boot		ext4	defaults	0	0
UUID=$ROOT_UUID	/           ext4	defaults	0	0
EOF

# Root password
passwd

# Time
rm /etc/localtime
ln -s /usr/share/zoneinfo/US/Eastern localtime

# Install custom packages
yum install -y vim tmux openssh

# Leave chroot
echo "Installtion complete."
echo "Perform any extra work necessary in chroot."
echo "Then, type 'exit' to complete installation outside of chroot. "