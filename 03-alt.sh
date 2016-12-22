#!/bin/sh

. ./vers

# Extract boot0 and uboot image
xzcat $WORKDIR/$SIMPLEIMAGE_XZ | dd status=none bs=1k skip=$boot0_position count=$boot0_size of=$BOOT0
xzcat $WORKDIR/$SIMPLEIMAGE_XZ | dd status=none bs=1k skip=$uboot_position count=$uboot_size of=$UBOOT

# Extract kernel
if [ ! -d $KERNEL ]
then
	mkdir $KERNEL
	tar Jxvf $WORKDIR/$LINUX_XZ -C $KERNEL
fi

# Extract initrd
# Thanks http://unix.stackexchange.com/questions/143961/unpack-modify-and-pack-initrd-as-a-user
tmpdir=$WORKDIR/initrd-tmp
fakeroot_savefile=$WORKDIR/initrd.fakeroot
mkdir $tmpdir
( \
	cd $tmpdir; \
	zcat ../$(basename $SRC_INITRD) | fakeroot -s ../$(basename $fakeroot_savefile) cpio -iv; \
)
rm -rfv $tmpdir/lib/modules/*
fakeroot -i $fakeroot_savefile -s $fakeroot_savefile cp -rv $KERNEL/lib/modules/* $tmpdir/lib/modules/
rm $tmpdir/lib/modules/3.10.104-2-pine64-longsleep/build
depmod -a -b $tmpdir $(basename $tmpdir/lib/modules/*)
( \
	cd $tmpdir; \
	find . | fakeroot -i ../$(basename $fakeroot_savefile) cpio -o -H newc | gzip -c > ../$(basename $DST_INITRD); \
)
