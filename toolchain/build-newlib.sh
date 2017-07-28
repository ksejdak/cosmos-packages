#!/bin/bash
# $1 - toolchain install path

if [ -z "$1" ]; then
    echo "No toolchain install path provided! Abort."
    exit 1
fi

# Toolchain packages.
NEWLIB=cosmos-newlib

BUILD_ROOT="$1"
REPOSITORY_ROOT=`git rev-parse --show-toplevel`
SCRIPT_ROOT="${REPOSITORY_ROOT}/toolchain"

# Building options.
TARGET=arm-cosmos
TOOLCHAIN_PREFIX="${BUILD_ROOT}/${TARGET}"
MAKEOPTS="-j9 -s"

# Fix compilation when using clang.
if [ ! $(gcc -v 2>&1 | grep clang > /dev/null) ]; then
    export CXXFLAGS="-fbracket-depth=512 -O2"
fi

# Download packages.
mkdir -p "${TOOLCHAIN_PREFIX}"
cd "${BUILD_ROOT}"

#[[ ! -d ${REPOSITORY_ROOT}/../${NEWLIB} ]] git clone git@github.com:ksejdak/cosmos-newlib.git "${REPOSITORY_ROOT}/.." && mkdir "${NEWLIB}/build"

# Apply patches.
#echo "PATCHING ${NEWLIB}"
#patch -d ${NEWLIB} -p1 < "${SCRIPT_ROOT}"/${NEWLIB}*.patch

# Build newlib.
echo "BUILDING ${NEWLIB}"
mkdir -p "${NEWLIB}/build"
cd "${NEWLIB}/build"

${REPOSITORY_ROOT}/../${NEWLIB}/configure --target=${TARGET} --prefix=${TOOLCHAIN_PREFIX} --disable-shared --disable-newlib-supplied-syscalls

make ${MAKEOPTS}
make ${MAKEOPTS} install

# Finalize.
if [ $? -ne 0 ]; then
    echo "BUILDING NEWLIB FAILED"
    exit 1
fi

echo "BUILDING NEWLIB DONE"
exit 0
