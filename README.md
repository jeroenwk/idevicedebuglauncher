# idevicedebuglauncher
**idevicedebuglauncher** is a web service on MacOS that can be used to attach a debugger to a remote application running on an iOS/tvOS device.
This can be used to activate JIT on emulators running on the Apple TV (Provenance, Dolphinios, ...)
It uses this library: https://github.com/libimobiledevice/libimobiledevice

## Quick install
    $ git clone https://github.com/jeroenwk/idevicedebuglauncher.git
    $ cd idevicedebuglauncher
    $ ./compile && ./install && ./run 

/doc/first_install.png 

## Run idevicedebuglauncher
- activate the 'Install as system service' switch
- allow to idevicedebuglauncher in the background within the login items preference (only the first time)
- once activate the list of devices is refreshed
- browse to http://localhost:8383/idevice_id by clicking on the link and check for the devices found
- use the button to pair the AppleTV
- closing the app will leave the background process running as system daemon

---

## Build idevicedebuglauncher
### Build within xcode
- open idevicedebuglauncher.xcodeproj
- build & run scheme 'idevicedebuglauncher'

### Build from command line
In the root of the project folder run:

    $ xcodebuild clean -scheme idevicedebuglauncher
    $ xcodebuild -scheme idevicedebuglauncher -configuration Release -derivedDataPath ./build
    
## Installing idevicedebuglauncher
You can just drag and drop or copy the application to the applications folder:

    $ cp -r ./build/Build/Products/Release/idevicedebuglauncher.app /Applications/
		 
Or: use build and use the installer package:

    $ xcodebuild clean -scheme installer 
    $ xcodebuild -scheme installer -configuration Release -derivedDataPath ./build
    $ open ./build/Build/Products/Release/
And double click 'idevicedebuglauncher.pkg'

## Test with curl
    $ curl http://localhost:8383/idevice_id -w "\n\n\n"
    $ curl http://localhost:8383/idevicedebug\?bundleId=com.jeroenwk.provenance -w "\n\n\n"

---

## Compile & install universal libraries
This step is optional because the repository includes already precompiled binaries for MacOS arm64 and x86_64 architectures:
- openssl: libcrypto-3.0.7, libssl-3.0.7
- libplist: libplist-2.2.0
- libusbmuxd: libusbmuxd-2.0.6
- libimobiledevice: libimobiledevice-1.3.0

 To make sure everything is working on your specific device or if you want to use newer versions of the libraries, a script can be used to re-compile them.
 
 The script basically does the following:
 - cleans a tmp directory if already used before
 - checks out the libraries and initialises them as git submodules
 - for each library it cleans, compiles and installs into a tmp directory
 - updates the rpaths so that all libraries can be installed next to each other in whatever location
 - copies the library inside the libs directory for the current architecture
 - included the library into a universal library

### Steps
Make sure you have the automake tools installed.

    $ brew install pkg-config autoconf automake libtool
Run the script 'install_libs.sh' inside its own directory.

    $ cd lib
    $ ./install_libs.sh

## Debugging a remote application
This is not implemented yet from the app yet!

    $ idevicedebug -n -u {device_id} run {bundle_id}

## Deamon configuration
The configuration is stored in:
/System/Volumes/Data/private/var/root/Library/Application\ Support/com.jeroenwk.idevicedebuglauncher/config.plist

The log file is stored in:
/usr/local/var/log/idevicedebuglauncher.log
