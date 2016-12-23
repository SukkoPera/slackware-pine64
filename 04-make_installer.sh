#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This script uses boot0 binary blob (as extracted from the Pine64 Android
# image) together with a correctly prefixed U-Boot and A DOS partition table
# to create a bootable SDcard image for the Pine64. If a Kernel and DTB is
# found in ../kernel, it is added as well.
#
# U-Boot tree:
# - https://github.com/longsleep/u-boot-pine64/tree/pine64-hacks
#
# Build the U-Boot tree and assemble it with ATF, SCP and FEX and put the
# resulting u-boot-with-dtb.bin file into the ../build directory. The
# u-boot-postprocess script provides an easy way to do all that.
#

. ./vers

set -e

out="slackinst.img"

if [ -z "$out" ]; then
	echo "\$out is empty!"
	exit 1
fi

#~ cleanup() {
	#~ if [ -d "$temp" ]; then
		#~ rm -rf "$temp"
	#~ fi
#~ }
#~ trap cleanup EXIT

set -x

# Create beginning of disk
dd if=/dev/zero bs=1M count=$((part_position/1024)) of="$out"
dd if="$BOOT0" conv=notrunc bs=1k seek=$boot0_position of="$out"
dd if="$UBOOT" conv=notrunc bs=1k seek=$uboot_position of="$out"

# Create boot file system (VFAT)
dd if=/dev/zero bs=1M count=$((boot_size-part_position/1024)) of=${out}1
mkfs.vfat -n BOOT ${out}1

# Add kernel & initramfs support
mcopy -m -i ${out}1 $KERNEL/boot/uEnv.txt.in ::uEnv.txt
mcopy -m -i ${out}1 $KERNEL/boot/Image.version ::
mcopy -sm -i ${out}1 $KERNEL/boot/pine64 ::
mcopy -m -i ${out}1 $DST_INITRD ::initrd.img

# Concatenate to main image
dd if=${out}1 conv=notrunc oflag=append bs=1M seek=$((part_position/1024)) of="$out"
rm -f ${out}1

# Add partition table
cat <<EOF | fdisk "$out"
o
n
p
1
$((part_position*2))

t
c
w
EOF

sync

echo "Done - image created: $out"
