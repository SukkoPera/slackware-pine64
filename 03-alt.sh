#!/bin/sh

. ./vers

# Extract boot0 and uboot image
xzcat $WORKDIR/$SIMPLEIMAGE_XZ | dd status=none bs=1k skip=$boot0_position count=$boot0_size of=$BOOT0
xzcat $WORKDIR/$SIMPLEIMAGE_XZ | dd status=none bs=1k skip=$uboot_position count=$uboot_size of=$UBOOT

# Extract kernel
mkdir $KERNEL
tar Jxvf $WORKDIR/$LINUX_XZ -C $KERNEL
