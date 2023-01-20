# idevicedebuglauncher
idevicedebuglauncher is a simple deamon on macos that can attach a debugger to an application on an iOS/tvOS device.
This can be used to activate JIT on emulators running on the Apple TV (Provenance, Dolphinios, ...)

## Compile libraries from source
    $ brew install pkg-config autoconf automake libtool
    
    $ cd externals
    $ git submodule update --init
    
    $ export PREFIX=$(pwd)/tmp
    $ export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig
    $ export LDFLAGS="-Wl,-rpath,@rpath"

### openssl
    $ cd ./openssl
    $ KERNEL_BITS=64 ./Configure --prefix=$(pwd)/../tmp '-Wl,-rpath,$@rpath'
    $ make
    $ make install
    
### libidevicemobile
	$ cd ../libplist
	$ ./autogen.sh --prefix=$PREFIX
	$ make
	$ make install
	
	$ cd ../libidevicemobile-glue
	$ ./autogen.sh --prefix=$PREFIX
	$ make
	$ make install
	
	$ cd ../libusbmuxd
	$ ./autogen.sh --prefix=$PREFIX
	$ make
	$ make install
	
	$ cd ../libidevicemobile
	$ ./autogen.sh --prefix=$PREFIX
	$ make
	$ make install
	
* if complaining on ltmain.sh, just run the commands again

## Install universal libraries
	$ cd ../tmp/lib
	$ cp libcrypto.3.dylib libssl.3.dylib libplist-2.0.3.dylib libusbmuxd-2.0.6.dylib libimobiledevice-glue-1.0.0.dylib libimobiledevice-1.0.6.dylib ../../../lib/$(uname -m)
	
	$ cd ../../../lib
	$ lipo arm64/libcrypto.3.dylib x86_64/libcrypto.3.dylib -output universal/libcrypto.3.dylib -create
	$ lipo arm64/libssl.3.dylib x86_64/libssl.3.dylib -output universal/libssl.3.dylib -create
	$ lipo arm64/libplist-2.0.3.dylib x86_64/libplist-2.0.3.dylib -output universal/libplist-2.0.3.dylib -create
	$ lipo arm64/libusbmuxd-2.0.6.dylib x86_64/libusbmuxd-2.0.6.dylib -output universal/libusbmuxd-2.0.6.dylib -create
	$ lipo arm64/libimobiledevice-glue-1.0.0.dylib x86_64/libimobiledevice-glue-1.0.0.dylib -output universal/libimobiledevice-glue-1.0.0.dylib -create
	$ lipo arm64/libimobiledevice-1.0.6.dylib x86_64/libimobiledevice-1.0.6.dylib -output universal/libimobiledevice-1.0.6.dylib -create


## Build idevicedebuglauncher
- open idevicedebuglauncher.xcodeproj
- build & run (you need to run the project in order to install later)
- browse to http://localhost:8181/idevice_id and check for the devices found (Note: the port nb is given as launch argument)
- stop

#### Install
run ./install.sh script to install daemon
This will install an excecutable (daemon) 'idevicedebuglauncher' in /usr/local/bin and the launchd configuration file com.jeroenwk.idevicedebuglauncher.plist in /Library/LaunchDaemons/

### Run
- Load the deamon with: sudo launchctl load /Library/LaunchDaemons/com.jeroenwk.idevicedebuglauncher.plist
- sudo launchctl list | grep idevicedebuglauncher
- browse to http://[ipaddress]:[port]/idevice_id and check for the devices found

### Launchd commands
- Load: sudo launchctl load /Library/LaunchDaemons/com.jeroenwk.idevicedebuglauncher.plist
- Unload: sudo launchctl unload /Library/LaunchDaemons/com.jeroenwk.idevicedebuglauncher.plist
- List: sudo launchctl list | grep idevicedebuglauncher
- Start: sudo launchctl start com.jeroenwk.idevicedebuglauncher
- Stop: sudo launchctl stop com.jeroenwk.idevicedebuglauncher

### curl
curl http://localhost:8181/idevice_id -w "\n\n\n"
curl http://localhost:8181/idevicedebug\?bundleId=com.jeroenwk.provenance -w "\n\n\n"

### Apple TV
#### pairing
- idevicepair -w pair
- after pairing note the udid of the Apple TV

#### debug
idevicedebug -n -u bbc1630faa46f5acb41938898ef7b26e912f9bf8 run com.jeroenwk.provenance
