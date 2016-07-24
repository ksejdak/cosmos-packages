#!/bin/bash

REPOSITORY_ROOT="$PWD/../.."
SRC_PATH="$REPOSITORY_ROOT/src"
BUILD_PATH="$REPOSITORY_ROOT/build"
BIN_PATH="$REPOSITORY_ROOT/bin/toolchain"

APP_NAME=binutils-2.26
APP_TAR_NAME=$APP_NAME.tar.bz2
APP_URL=https://ftp.gnu.org/gnu/binutils/$APP_TAR_NAME

TOOLCHAIN_PREFIX=arm-cosmos

mkdir -p $SRC_PATH
mkdir -p $BUILD_PATH/$APP_NAME

if [ ! -d $SRC_PATH/$APP_NAME ]; then
    if [ ! -f $APP_TAR_NAME ]; then
        wget $APP_URL
    fi

    tar jxf $APP_TAR_NAME -C $SRC_PATH

	for patchfile in *.patch; do
		patch -d $SRC_PATH/$APP_NAME -p1 < $patchfile
	done
fi

cd $BUILD_PATH/$APP_NAME

$SRC_PATH/$APP_NAME/configure --target=$TOOLCHAIN_PREFIX --prefix=$BIN_PATH --with-sysroot=$BIN_PATH/$TOOLCHAIN_PREFIX
make -j5
make install

cd -
