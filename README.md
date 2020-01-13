# install-custom-centos

These scripts create a minimal install of CentOS 8 (even more so than the standard minimal installtion) via a chroot-style installation similar to `debbootstrap` or `pacstrap`.

These scripts were designed to be ran under the CentOS 7 LiveCD (CentOS 8 does not seem to provide a LiveCD). Installtion is simple, and does not provide many options. The final installtion includes no desktop environment, or many other features at all, but it does function.

The script assumes the machine is 64-bit and supports EFI.

The partition format is as follows:

| Partition Number | Mount point | Format | Size      |
| ---------------- | ----------- | ------ | --------- |
| 1                | /boot/efi   | vfat   | 512 MiB   |
| 2                | /boot       | ext4   | 1 GiB     |
| 3                | /           | ext4   | remaining |

The installation drive is formatted and can be configured by setting the `DRIVE` environment variable in `install.sh`.

## Installation

1. Boot the CentOS 7 LiveCD found [here](http://mirror.umd.edu/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-LiveGNOME-1908.iso).
2. After the system boots, switch to TTY2 with `Ctrl+Alt+F2). Log in as root.
3. Install git: `yum install git`
4. Clone this repo: `git clone https://github.com/jtvd78/install-custom-centos.git`
5. `cd` into the installation directory: `cd install-custom-centos`
6. Run the start script: `chmod +x start.sh && ./start.sh`

The installation will proceed without any user interaction until the end where it will ask you to set a root password. Afterwards, a bash shell is opened in the `chroot` where any final configuration can be performed before the installation is finished.

## Post-Installtion

`reboot` the system. The system should now boot into the newly installed OS. Re-clone the git repo and run `post-install.sh` to finish the installation.

## Extra Information

These scripts were based on the [manual install](https://wiki.centos.org/HowTos/ManualInstall) page on the CentOS wiki. Something seems to be odd with the page, so I needed to follow the guide in the [raw format](https://wiki.centos.org/HowTos/ManualInstall?action=raw). The page is out-of-date and is meant to install a CentOS 7 image. Further, following the guide completely does not configure a bootable system. Notably, it does not install the kernel or install `shim` which seems to be necessary for booting.

## A Warning

These scripts are by no means complete but they do install a bootable system. These scrips are provided without any warranty. Please do not use this on any installed system where you could potentially lose any data you are not afraid of not getting back.

## Yes, I know Kickstart exists

Writing this was a learning exercise for me. Though this is no LFS, I definitely learned a good bit about how linux is put together and configured -- mostly in regards to the boot process / setting up GRUB.
