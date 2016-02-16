#!/usr/bin/env bash

echo "==> Install guest tools"

VMTOOLS_BUILD_DIR=/tmp/vmtools
VMTOOLS_ARCHIVE_DIR=/tmp/vmtools-archive

mkdir -p $VMTOOLS_BUILD_DIR $VMTOOLS_ARCHIVE_DIR

mount -o loop $HOME_DIR/linux.iso $VMTOOLS_BUILD_DIR

tar xzf $VMTOOLS_BUILD_DIR/VMwareTools-*.tar.gz -C $VMTOOLS_ARCHIVE_DIR
$VMTOOLS_ARCHIVE_DIR/vmware-tools-distrib/vmware-install.pl --force-install

# https://dantehranian.wordpress.com/2014/08/19/vagrant-vmware-resolving-waiting-for-hgfs-kernel-module-timeouts/
echo "answer AUTO_KMODS_ENABLED yes" | tee -a /etc/vmware-tools/locations

umount $VMTOOLS_BUILD_DIR

rm -rf $VMTOOLS_BUILD_DIR $VMTOOLS_ARCHIVE_DIR

rm -f $HOME_DIR/*.iso