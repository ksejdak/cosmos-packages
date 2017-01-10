#!/bin/bash

REPOSITORY_ROOT=`git rev-parse --show-toplevel`
SRC_PATH="$REPOSITORY_ROOT/src"
BUILD_PATH="$REPOSITORY_ROOT/build"
BIN_PATH="$REPOSITORY_ROOT/bin/toolchain"

APP_NAME=gmp-6.1.2
APP_TAR_NAME=$APP_NAME.tar.bz2
APP_URL=https://gmplib.org/download/gmp/$APP_TAR_NAME

mkdir -p $SRC_PATH
mkdir -p $BUILD_PATH/$APP_NAME

if [ ! -d $SRC_PATH/$APP_NAME ]; then
    if [ ! -f $APP_TAR_NAME ]; then
        wget $APP_URL
    fi

    tar jxf $APP_TAR_NAME -C $SRC_PATH
fi

cd $BUILD_PATH/$APP_NAME

$SRC_PATH/$APP_NAME/configure --prefix=$BUILD_PATH --disable-shared
make -j5
make install

cd -
