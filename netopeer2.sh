#!/usr/bin/bash

set -x

start_dir=`pwd`

toolchain_dir=/home/shure/aarch64-xilinx-linux

rm -rf sysroot
cp -rf $toolchain_dir/sysroot .
sysroot_dir=$start_dir/sysroot

rm -f cross.cmake
touch cross.cmake
echo "set(CMAKE_SYSTEM_NAME Linux)" >> cross.cmake
echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> cross.cmake
echo "set(CMAKE_SYSROOT $sysroot_dir)" >> cross.cmake
echo "set(CMAKE_STAGING_PREFIX $sysroot_dir)" >> cross.cmake
echo "set(CMAKE_INSTALL_PREFIX $sysroot_dir)" >> cross.cmake
echo "set(tools $toolchain_dir/usr/bin/aarch64-xilinx-linux)" >> cross.cmake
echo "set(CMAKE_C_COMPILER \${tools}/aarch64-xilinx-linux-gcc)" >> cross.cmake
echo "set(CMAKE_CXX_COMPILER \${tools}/aarch64-xilinx-linux-g++)" >> cross.cmake
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> cross.cmake
echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> cross.cmake
echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> cross.cmake
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)" >> cross.cmake
echo "include_directories(\${CMAKE_STAGING_PREFIX}/include)" >> cross.cmake

export PKG_CONFIG_PATH=$sysroot_dir/lib/pkgconfig
export QEMU_LD_PREFIX=$sysroot_dir

cd $start_dir
wget https://www.zlib.net/zlib-1.3.1.tar.gz
tar -xf zlib-1.3.1.tar.gz
mkdir zlib-1.3.1/build
cd zlib-1.3.1/build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake -DCMAKE_INSTALL_PREFIX=$sysroot_dir ..
make install

cd $start_dir
git clone https://github.com/PCRE2Project/pcre2.git
cd pcre2
mkdir build ; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake -DCMAKE_INSTALL_PREFIX=$sysroot_dir ..
make install

cd $start_dir
wget https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz
tar -xf libxcrypt-4.4.36.tar.xz
cd libxcrypt-4.4.36
./configure --host=arm64 CC=$toolchain_dir/usr/bin/aarch64-xilinx-linux/aarch64-xilinx-linux-gcc CFLAGS=--sysroot=$sysroot_dir --prefix=$sysroot_dir
make
make install

cd $start_dir
git clone https://github.com/openssl/openssl.git
cd openssl
./Configure linux-aarch64 --cross-compile-prefix=$toolchain_dir/usr/bin/aarch64-xilinx-linux/aarch64-xilinx-linux- --prefix=$sysroot_dir "--sysroot=$sysroot_dir"
make -j 30
make install

cd $start_dir
git clone https://git.libssh.org/projects/libssh.git
cd libssh
mkdir build ; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake -DCMAKE_INSTALL_PREFIX=$sysroot_dir ..
make install

cd $start_dir
git clone https://github.com/curl/curl.git
cd curl
mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake -DCMAKE_INSTALL_PREFIX=$sysroot_dir ..
make install

cd $start_dir
git clone https://github.com/CESNET/libyang.git
cd libyang
mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake  ..
make install

cd $start_dir
git clone https://github.com/CESNET/libnetconf2.git
cd libnetconf2
mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake  ..
make install

cd $start_dir
git clone https://github.com/sysrepo/sysrepo.git
cd sysrepo
mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake  ..
make install

cd $start_dir
git clone https://github.com/shure/netopeer2.git
# git clone https://github.com/CESNET/netopeer2.git
cd netopeer2
mkdir build; cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$start_dir/cross.cmake  ..
make install
