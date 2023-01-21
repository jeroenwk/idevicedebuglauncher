#!/bin/sh
export LIB_DIR=$(pwd)
cd ..
export EXTERNALS_DIR=$(pwd)/externals && echo "EXTERNALS_DIR: ${EXTERNALS_DIR}"
export PREFIX=$EXTERNALS_DIR/tmp && echo "PREFIX: ${PREFIX}"
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig && echo "PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}\n\n"
rm -fr $EXTERNALS_DIR/tmp

sleep 1 && echo "START checkout libraries"
cd $EXTERNALS_DIR
git submodule update --init
echo "END checkout libraries\n\n"

sleep 1 && echo "START openssl"
cd $EXTERNALS_DIR/openssl
KERNEL_BITS=64 ./Configure --prefix=$PREFIX
make clean && make && make install
echo && sleep 1 && echo
echo "openssl rpath updates"
install_name_tool -id @rpath/libcrypto.3.dylib $PREFIX/lib/libcrypto.3.dylib
otool -D $PREFIX/lib/libcrypto.3.dylib
install_name_tool -id @rpath/libssl.3.dylib $PREFIX/lib/libssl.3.dylib
otool -D $PREFIX/lib/libssl.3.dylib
install_name_tool -change $PREFIX/lib/libcrypto.3.dylib @rpath/libcrypto.3.dylib $PREFIX/lib/libssl.3.dylib
otool -L $PREFIX/lib/libssl.3.dylib
echo "install in ${LIB_DIR}"
cp $PREFIX/lib/libcrypto.3.dylib ${LIB_DIR}/$(uname -m)/
cp $PREFIX/lib/libssl.3.dylib ${LIB_DIR}/$(uname -m)/
echo "make openssl universal"
lipo -create ${LIB_DIR}/arm64/libcrypto.3.dylib ${LIB_DIR}/x86_64/libcrypto.3.dylib -output ${LIB_DIR}/universal/libcrypto.3.dylib
lipo -create ${LIB_DIR}/arm64/libssl.3.dylib ${LIB_DIR}/x86_64/libssl.3.dylib -output ${LIB_DIR}/universal/libssl.3.dylib
echo "END openssl\n\n"

sleep 1 && echo "START libplist"
cd $EXTERNALS_DIR/libplist
./autogen.sh --prefix=$PREFIX --without-cython
./autogen.sh --prefix=$PREFIX --without-cython # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "libplist rpath updates"
install_name_tool -id @rpath/libplist-2.0.3.dylib $PREFIX/lib/libplist-2.0.3.dylib
otool -D $PREFIX/lib/libplist-2.0.3.dylib
echo "install in ${LIB_DIR}"
cp $PREFIX/lib/libplist-2.0.3.dylib ${LIB_DIR}/$(uname -m)/
echo "make libplist universal"
lipo -create ${LIB_DIR}/arm64/libplist-2.0.3.dylib ${LIB_DIR}/x86_64/libplist-2.0.3.dylib -output ${LIB_DIR}/universal/libplist-2.0.3.dylib
echo "END libplist\n\n"

sleep 1 && echo "START libimobiledevice-glue"
cd $EXTERNALS_DIR/libimobiledevice-glue
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "libimobiledevice-glue rpath updates"
install_name_tool -id @rpath/libimobiledevice-glue-1.0.0.dylib $PREFIX/lib/libimobiledevice-glue-1.0.0.dylib
otool -D $PREFIX/lib/libimobiledevice-glue-1.0.0.dylib
echo "install in ${LIB_DIR}"
cp $PREFIX/lib/libimobiledevice-glue-1.0.0.dylib ${LIB_DIR}/$(uname -m)/
echo "make libimobiledevice-glue universal"
lipo -create ${LIB_DIR}/arm64/libimobiledevice-glue-1.0.0.dylib ${LIB_DIR}/x86_64/libimobiledevice-glue-1.0.0.dylib -output ${LIB_DIR}/universal/libimobiledevice-glue-1.0.0.dylib
echo "END libimobiledevice-glue\n\n"

sleep 1 && echo "START libusbmuxd"
cd $EXTERNALS_DIR/libusbmuxd
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "libusbmuxd rpath updates"
install_name_tool -id @rpath/libusbmuxd-2.0.6.dylib $PREFIX/lib/libusbmuxd-2.0.6.dylib
otool -D $PREFIX/lib/libusbmuxd-2.0.6.dylib
echo "install in ${LIB_DIR}"
cp $PREFIX/lib/libusbmuxd-2.0.6.dylib ${LIB_DIR}/$(uname -m)/
echo "make libusbmuxd universal"
lipo -create ${LIB_DIR}/arm64/libusbmuxd-2.0.6.dylib ${LIB_DIR}/x86_64/libusbmuxd-2.0.6.dylib -output ${LIB_DIR}/universal/libusbmuxd-2.0.6.dylib
echo "END libusbmuxd\n\n"

sleep 1 && echo "START libimobiledevice"
cd $EXTERNALS_DIR/libimobiledevice
./autogen.sh --prefix=$PREFIX
./autogen.sh --prefix=$PREFIX # twice because missing ltmain.sh
make clean && make && make install
echo && sleep 1 && echo
echo "libimobiledevice rpath updates"
install_name_tool -id @rpath/libimobiledevice-1.0.6.dylib $PREFIX/lib/libimobiledevice-1.0.6.dylib
otool -D $PREFIX/lib/libimobiledevice-1.0.6.dylib
echo "install in ${LIB_DIR}"
cp $PREFIX/lib/libimobiledevice-1.0.6.dylib ${LIB_DIR}/$(uname -m)/
echo "make libimobiledevice universal"
lipo -create ${LIB_DIR}/arm64/libimobiledevice-1.0.6.dylib ${LIB_DIR}/x86_64/libimobiledevice-1.0.6.dylib -output ${LIB_DIR}/universal/libimobiledevice-1.0.6.dylib
echo "END libimobiledevice\n\n"
