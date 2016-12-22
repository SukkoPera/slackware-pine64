#!/bin/sh

. ./vers

[ ! -d $WORKDIR ] && mkdir $WORKDIR

cd $WORKDIR

# Kernel
wget -c https://www.stdin.xyz/downloads/people/longsleep/pine64-images/linux/linux-pine64-${LINUX_VERSION}.tar.xz

# longsleep's simpleimage, from which we extract boot0 and uboot
wget -c https://www.stdin.xyz/downloads/people/longsleep/pine64-images/simpleimage-pine64-${SIMPLEIMAGE_VERSION}.img.xz
#~ wget -c http://ftp.arm.slackware.com/slackwarearm/slackwarearm-devtools/minirootfs/roots/slack-${SLACKWARE_VERSION}-miniroot_${SLACKWARE_MINIROOTFS_VERSION}.tar.xz

#~ wget -q -O - http://ftp.arm.slackware.com/slackwarearm/slackwarearm-devtools/minirootfs/roots/slack-${SLACKWARE_VERSION}-miniroot_details.txt | grep -C1 "User"

# Slackware ARM installer image
wget -c ftp://ftp.arm.slackware.com/slackwarearm/slackwarearm-${SLACKWARE_VERSION}/isolinux/initrd-armv7.img
