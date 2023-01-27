#!/bin/sh
export LIB_DIR=$(pwd)
cd ..
export EXTERNALS_DIR=$(pwd)/externals && echo "EXTERNALS_DIR: ${EXTERNALS_DIR}"
export PREFIX=$EXTERNALS_DIR/build && echo "PREFIX: ${PREFIX}"
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig && echo "PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}\n\n"
rm -fr $EXTERNALS_DIR/build

sleep 1 && echo "START checkout libraries"
cd $EXTERNALS_DIR
git submodule update --init
echo "END checkout libraries\n\n"

sleep 1 && echo "START openssl"
cd $EXTERNALS_DIR/openssl
KERNEL_BITS=64 ./Configure --prefix=$PREFIX
make clean && make && make install
echo && sleep 1 && echo
echo "END openssl\n\n"

sleep 1 && echo "START libplist"
cd $EXTERNALS_DIR/libplist
./autogen.sh --prefix=$PREFIX --without-cython
./autogen.sh --prefix=$PREFIX --without-cython # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "END libplist\n\n"

sleep 1 && echo "START libimobiledevice-glue"
cd $EXTERNALS_DIR/libimobiledevice-glue
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "END libimobiledevice-glue\n\n"

sleep 1 && echo "START libusbmuxd"
cd $EXTERNALS_DIR/libusbmuxd
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "END libusbmuxd\n\n"

sleep 1 && echo "START libimobiledevice"
cd $EXTERNALS_DIR/libimobiledevice
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "END libimobiledevice\n\n"
