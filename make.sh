#!/bin/bash

set -e

function main {
  check_params $1
  initialize $1
  #mount original image
  mkdir -p $MOUNTIMAGE
  mount -o loop $1 $MOUNTIMAGE

  #copy files to writable place
  rsync -rv $MOUNTIMAGE/ $BUILD
  chmod -R 777 $BUILD

  #copy files from this project
  rsync -rv $HERE/cd-files/ $BUILD

  #make iso
  cd $BUILD
  mkisofs -r -V "Custom Ubuntu Install CD" \
              -cache-inodes \
              -joliet-long -l -b isolinux/isolinux.bin \
              -c isolinux/boot.cat -no-emul-boot \
              -boot-load-size 4 -boot-info-table \
              -o $IMAGE $BUILD
  cd -

  #delete writable place
  rm -rf $BUILD

  #unmount image
  umount $MOUNTIMAGE
}

function scriptdir {
  pushd `dirname $0` > /dev/null
  SCRIPTPATH=`pwd -P`
  popd > /dev/null
  echo $SCRIPTPATH
}

function initialize {
  BUILD=/tmp/custom-cd/
  IMAGE=/tmp/custom.iso
  MOUNTIMAGE=/tmp/custom-cd-source
  HERE=`scriptdir`
  STARTINGDIR=`pwd`
  ORIGINALIMAGE=$1
}

function check_params {
  if [ -z "$1" ]; then
    echo requires path to ubuntu iso as first arg
    exit 1
  fi
  if [ $(id -u) != "0" ]; then
    echo must be root
    exit 1
  fi
}

main $1

