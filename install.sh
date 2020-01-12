export DRIVE=/dev/sda

$ Partition the disk
parted --script $DRIVE \
	mklabel gpt \
	mkpart primary 1MiB 513MiB \
	mkpart primary 513MiB 1537MiB \
	mkpart primary 1537MiB 100% \
	set 1 boot on

# Format the disk
mkfs.vfat -F32 -n EFI "${DRIVE}1"
mkfs.ext4 -L BOOT "${DRIVE}2"
mkfs.ext4 -L ROOT "${DRIVE}3"

# Mount the partitions
mkdir /target
mount "${DRIVE}3" /target
mkdir /target/boot
mount "${DRIVE}2" /target/boot
mkdir /target/boot/efi
mount "${DRIVE}1" /target/boot/efi

# Install yum
rpm --root /target -i http://mirror.centos.org/centos/8.0.1905/BaseOS/x86_64/os/Packages/centos-release-8.0-0.1905.0.9.el8.x86_64.rpm
mkdir -p /etc/pki/rpm-gpg && cp /target/etc/pki/rpm-gpg/* /etc/pki/rpm-gpg
yum -y --installroot=/target --releasever=8 install yum

# Prepare chroot
cp /etc/resolv.conf /target/etc
mount --bind /dev/ /target/dev/
mount -t proc procfs /target/proc/
mount -t sysfs sysfs /target/sys/
mount -t efivarfs efivarfs /target/sys/firmware/efi/efivars/

cp install-chroot.sh /target/install.sh

# Enter chroot
chroot /target /bin/bash -c "bash /install.sh && bash && rm /install.sh"

# Unmount
 mount | grep target | awk '{ print $3 }' | xargs umount -lf