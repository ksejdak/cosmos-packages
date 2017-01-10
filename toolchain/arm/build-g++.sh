#!/bin/bash

REPOSITORY_ROOT=`git rev-parse --show-toplevel`
SRC_PATH="$REPOSITORY_ROOT/src"
BUILD_PATH="$REPOSITORY_ROOT/build"
BIN_PATH="$REPOSITORY_ROOT/bin/toolchain"

APP_NAME=gcc-6.1.0
APP_TAR_NAME=$APP_NAME.tar.bz2
APP_URL=ftp://ftp.gnu.org/gnu/gcc/$APP_NAME/$APP_TAR_NAME

TOOLCHAIN_PREFIX=arm-cosmos

mkdir -p $SRC_PATH
mkdir -p $BUILD_PATH/$APP_NAME

if [ ! -d $SRC_PATH/$APP_NAME ]; then
    if [ ! -f $APP_TAR_NAME ]; then
        wget $APP_URL
    fi

    tar jxf $APP_TAR_NAME -C $SRC_PATH

	for patchfile in gcc*.patch; do
		patch -d $SRC_PATH/$APP_NAME -p1 < $patchfile
	done
fi

###########################################
# PHASE 1 - GCC without newlib and C++.
###########################################

cd $BUILD_PATH/$APP_NAME

$SRC_PATH/$APP_NAME/configure --target=$TOOLCHAIN_PREFIX --prefix=$BUILD_PATH --enable-languages=c,c++ --with-gmp=$BUILD_PATH --with-mpfr=$BUILD_PATH \
                              --with-mpc=$BUILD_PATH --with-sysroot=$BUILD_PATH/$TOOLCHAIN_PREFIX --with-arch=armv7-a --with-fpu=neon-vfpv4 \
                              --with-mode=thumb

make -j5 all-gcc all-target-libgcc all-target-libstdc++-v3
make install-gcc install-target-libgcc install-target-libstdc++-v3

cd -
