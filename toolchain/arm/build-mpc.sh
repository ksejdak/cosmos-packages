#!/bin/bash

REPOSITORY_ROOT="$PWD/../.."
SRC_PATH="$REPOSITORY_ROOT/src"
BUILD_PATH="$REPOSITORY_ROOT/build"
BIN_PATH="$REPOSITORY_ROOT/bin/toolchain"

APP_NAME=mpc-1.0.3
APP_TAR_NAME=$APP_NAME.tar.gz
APP_URL=ftp://ftp.gnu.org/gnu/mpc/$APP_TAR_NAME

TOOLCHAIN_PREFIX=arm-cosmos

mkdir -p $SRC_PATH
mkdir -p $BUILD_PATH/$APP_NAME

if [ ! -d $SRC_PATH/$APP_NAME ]; then
    if [ ! -f $APP_TAR_NAME ]; then
        wget $APP_URL
    fi

    tar xf $APP_TAR_NAME -C $SRC_PATH
fi

cd $BUILD_PATH/$APP_NAME

$SRC_PATH/$APP_NAME/configure --target=$TOOLCHAIN_PREFIX --prefix=$BUILD_PATH --with-gmp=$BUILD_PATH --with-mpfr=$BUILD_PATH --disable-shared
make -j5
make install

cd -
