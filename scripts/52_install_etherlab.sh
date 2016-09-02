#!/bin/bash

set -e
set -o nounset

if [ $# -ne 1 ] || ! [ -d $1 ]; then
	echo -e "Usage:\n $0 <rootfs_mount>\n\nexample:\n $0 /tmp/rootfs\n\n"
	exit -1
fi

ROOTFS_MOUNT=$1

ETHERLAB=ethercat-hg
KERNEL=kernel

LINARO=gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf
CROSS_PATH=`pwd`/tools/${LINARO}/bin
CROSS_PREFIX=${CROSS_PATH}/arm-linux-gnueabihf-

pushd ${ETHERLAB}
make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} INSTALL_MOD_PATH=${ROOTFS_MOUNT} modules_install
make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} DESTDIR=${ROOTFS_MOUNT} PATH=${PATH}:${CROSS_PATH} install
popd

mkdir -p ${ROOTFS_MOUNT}/etc/sysconfig/
cp -a ${ROOTFS_MOUNT}/opt/etherlab/etc/sysconfig/ethercat ${ROOTFS_MOUNT}/etc/sysconfig/
sed -b -i 's/MASTER0_DEVICE=\"\"/MASTER0_DEVICE=\"ff:ff:ff:ff:ff:ff\"/' ${ROOTFS_MOUNT}/etc/sysconfig/ethercat
sed -b -i 's/DEVICE_MODULES=\"\"/DEVICE_MODULES=\"ccat\"/' ${ROOTFS_MOUNT}/etc/sysconfig/ethercat
ln -fs /opt/etherlab/etc/init.d/ethercat ${ROOTFS_MOUNT}/etc/init.d/
