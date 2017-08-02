#!/bin/bash
# $1 - toolchain install path

if [ -z "$1" ]; then
    echo "No toolchain install path provided! Abort."
    exit 1
fi

# Toolchain packages.
GMP=gmp-6.1.2
MPFR=mpfr-3.1.5
MPC=mpc-1.0.3
BINUTILS=binutils-2.28
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

[[ ! -f ${GMP}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/gmp/${GMP}.tar.bz2"
[[ ! -f ${MPFR}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/mpfr/${MPFR}.tar.bz2"
[[ ! -f ${MPC}.tar.gz ]] && wget "ftp://ftp.gnu.org/gnu/mpc/${MPC}.tar.gz"
[[ ! -f ${BINUTILS}.tar.bz2 ]] && wget "http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2"
[[ ! -f ${GCC}.tar.bz2 ]] && wget "http://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2"

# Extract packages.
[[ ! -d ${GMP} ]] && tar jxf ${GMP}.tar.bz2 && mkdir -p "${GMP}/build"
[[ ! -d ${MPFR} ]] && tar jxf ${MPFR}.tar.bz2 && mkdir -p "${MPFR}/build"
[[ ! -d ${MPC} ]] && tar xf ${MPC}.tar.gz && mkdir -p "${MPC}/build"

if [ ! -d ${BINUTILS} ]; then
    tar jxf ${BINUTILS}.tar.bz2
    echo "PATCHING ${BINUTILS}"
    patch -d ${BINUTILS} -p1 < "${SCRIPT_ROOT}"/${BINUTILS}*.patch
    mkdir -p "${BINUTILS}/build"
fi

if [ ! -d ${GCC} ]; then
    tar jxf ${GCC}.tar.bz2
    echo "PATCHING ${GCC}"
    patch -d ${GCC} -p1 < "${SCRIPT_ROOT}"/${GCC}*.patch
    mkdir -p "${GCC}/build"
fi

# Build GMP.
echo "BUILDING ${GMP}"
cd "${GMP}/build"

../configure --prefix="${TOOLCHAIN_PREFIX}" \
             --disable-shared \
             --disable-nls \
             --enable-cxx

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build MPFR.
echo "BUILDING ${MPFR}"
cd "${MPFR}/build"

../configure --prefix="${TOOLCHAIN_PREFIX}" \
             --with-gmp="${TOOLCHAIN_PREFIX}" \
             --disable-shared \
             --disable-nls

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
             --disable-shared \
             --disable-nls

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build Binutils.
echo "BUILDING ${BINUTILS}"
cd "${BINUTILS}/build"

../configure --target=${TARGET} \
             --prefix="${TOOLCHAIN_PREFIX}" \
             --with-sysroot="${TOOLCHAIN_PREFIX}/${TARGET}" \
             --disable-shared \
             --disable-nls \
             --enable-interwork \
             --enable-multilib
             --enable-plugins

make ${MAKEOPTS}
make ${MAKEOPTS} install

cd -

# Build GCC (Phase 1).
echo "BUILDING ${GCC} (PHASE 1)"
cd "${GCC}/build"

../configure --target=${TARGET} \
             --prefix="${TOOLCHAIN_PREFIX}" \
             --with-sysroot="${TOOLCHAIN_PREFIX}/${TARGET}" \
             --with-gmp="${TOOLCHAIN_PREFIX}" \
             --with-mpfr="${TOOLCHAIN_PREFIX}" \
             --with-mpc="${TOOLCHAIN_PREFIX}" \
             --with-newlib \
             --with-mode=thumb \
             --with-abi=aapcs \
             --without-headers \
             --enable-languages=c \
             --enable-threads=posix \
             --disable-nls \
             --disable-decimal-float \
             --disable-libffi \
             --disable-libgomp \
             --disable-libmudflap \
             --disable-libquadmath \
             --disable-libssp \
             --disable-libstdcxx-pch \
             --disable-shared \
             --disable-tls

make ${MAKEOPTS} all-gcc
make ${MAKEOPTS} install-gcc

# Finalize.
if [ $? -ne 0 ]; then
    echo "BUILDING TOOLCHAIN FAILED"
    exit 1
fi

echo "BUILDING TOOLCHAIN DONE"
exit 0
