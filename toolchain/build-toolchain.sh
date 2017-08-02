#!/bin/bash
# $1 - toolchain install path

if [ -z "$1" ]; then
    echo "No toolchain install path provided! Abort."
    exit 1
fi

# Toolchain packages.
BINUTILS=binutils-2.28
GMP=gmp-6.1.2
MPFR=mpfr-3.1.5
MPC=mpc-1.0.3
GCC=gcc-7.1.0

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

[[ ! -f ${BINUTILS}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2"
[[ ! -f ${GMP}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/gmp/${GMP}.tar.bz2"
[[ ! -f ${MPFR}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/mpfr/${MPFR}.tar.bz2"
[[ ! -f ${MPC}.tar.gz ]] && wget "ftp://ftp.gnu.org/gnu/mpc/${MPC}.tar.gz"
[[ ! -f ${GCC}.tar.bz2 ]] && wget "http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2"

# Extract packages.
if [ ! -d ${BINUTILS} ]; then
    tar jxf ${BINUTILS}.tar.bz2
    echo "PATCHING ${BINUTILS}"
    patch -d ${BINUTILS} -p1 < "${SCRIPT_ROOT}"/${BINUTILS}*.patch
    mkdir -p "${BINUTILS}/build"
fi

[[ ! -d ${GMP} ]] && tar jxf ${GMP}.tar.bz2 && mkdir -p "${GMP}/build"
[[ ! -d ${MPFR} ]] && tar jxf ${MPFR}.tar.bz2 && mkdir -p "${MPFR}/build"
[[ ! -d ${MPC} ]] && tar xf ${MPC}.tar.gz && mkdir -p "${MPC}/build"

if [ ! -d ${GCC} ]; then
    tar jxf ${GCC}.tar.bz2
    echo "PATCHING ${GCC}"
    patch -d ${GCC} -p1 < "${SCRIPT_ROOT}"/${GCC}*.patch
    mkdir -p "${GCC}/build"
fi

# Build Binutils.
echo "BUILDING ${BINUTILS}"
cd "${BINUTILS}/build"

../configure --target=${TARGET} \
             --prefix="${TOOLCHAIN_PREFIX}" \
             --with-sysroot="${TOOLCHAIN_PREFIX}/${TARGET}"

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build GMP.
echo "BUILDING ${GMP}"
cd "${GMP}/build"

../configure --prefix="${TOOLCHAIN_PREFIX}" \
             --disable-shared

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build MPFR.
echo "BUILDING ${MPFR}"
cd "${MPFR}/build"

../configure --prefix="${TOOLCHAIN_PREFIX}" \
             --with-gmp="${TOOLCHAIN_PREFIX}" \
             --disable-shared

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build MPC.
echo "BUILDING ${MPC}"
cd "${MPC}/build"

../configure --target=${TARGET} \
             --prefix="${TOOLCHAIN_PREFIX}" \
             --with-gmp="${TOOLCHAIN_PREFIX}" \
             --with-mpfr="${TOOLCHAIN_PREFIX}" \
             --disable-shared

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build GCC.
echo "BUILDING ${GCC}"
cd "${GCC}/build"

../configure --target=${TARGET} \
             --prefix="${TOOLCHAIN_PREFIX}" \
             --with-sysroot="${TOOLCHAIN_PREFIX}/${TARGET}" \
             --with-gmp="${TOOLCHAIN_PREFIX}" \
             --with-mpfr="${TOOLCHAIN_PREFIX}" \
             --with-mpc="${TOOLCHAIN_PREFIX}" \
             --enable-languages=c,c++ \
             --with-arch=armv7-a \
             --with-fpu=neon-vfpv4 \
             --with-mode=thumb \
             --with-abi=aapcs \
             --with-newlib \
             --disable-libssp \
             --disable-nls

make ${MAKEOPTS} all-gcc
make ${MAKEOPTS} install-gcc

# Finalize.
if [ $? -ne 0 ]; then
    echo "BUILDING TOOLCHAIN FAILED"
    exit 1
fi

echo "BUILDING TOOLCHAIN DONE"
exit 0
