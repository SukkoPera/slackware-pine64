#!/bin/sh

. ./vers

[[ "x$UID" != "x0" ]] && echo "run as root" && exit

xzcat $WORKDIR/$SIMPLEIMAGE_XZ > $SIMPLEIMAGE
loopdev=$(losetup -f -P --show $SIMPLEIMAGE)
echo "Image has been setup on loop device $loopdev"

# Repartition
#/bin/echo -e "d\n2\nn\np\n2\n143360\n\nw\n" | sudo fdisk $loopdev
tune2fs -m 0 ${loopdev}p2
mount ${loopdev}p2 $SD_MOUNTPNT || exit $?
#mkfs.ext4 -O ^has_journal -b 4096 -L rootfs -U deadbeef-dead-beef-dead-beefdeadbeef ${loopdev}p2
rm -rf $SD_MOUNTPNT/*
mkdir -p $SD_MOUNTPNT/bootenv
mount ${loopdev}p1 $SD_MOUNTPNT/bootenv

tar --numeric-owner -C $SD_MOUNTPNT/ -xpJf $WORKDIR/$MINIROOT_XZ
echo tar --numeric-owner -C $SD_MOUNTPNT/ -xpJf $WORKDIR/$LINUX_XZ
exit 1
cp -R $SD_MOUNTPNT/boot/* $SD_MOUNTPNT/bootenv/

cat <<EOF > $SD_MOUNTPNT/etc/modprobe.d/blacklist
8723bs_vq0
EOF

cat <<EOF >> $SD_MOUNTPNT/etc/rc.d/rc.modprobe.local
/sbin/modprobe 8723bs
EOF

cat <<EOF >> $SD_MOUNTPNT/etc/fstab

/dev/mmcblk0p2	/	ext4	defaults,discard	1	1
tmpfs	/tmp	tmpfs	defaults,mode=777	0	0
EOF

cat <<EOF > $SD_MOUNTPNT/etc/motd
 ____  _             __   _  _
|  _ \(_)_ __   ___ / /_ | || |
| |_) | | '_ \ / _ \ '_ \| || |_
|  __/| | | | |  __/ (_) |__   _|
|_|   |_|_| |_|\___|\___/   |_|
                                 Slackware
EOF

cp $CWD/pine64-kernel.SlackBuild $SD_MOUNTPNT/root

umount $SD_MOUNTPNT/bootenv
umount $SD_MOUNTPNT
sync

losetup -d $loopdev

echo "All done, if no errors appeared, write $SIMPLEIMAGE to a MicroSD card, insert it in the Pine64 and boot it :)"
