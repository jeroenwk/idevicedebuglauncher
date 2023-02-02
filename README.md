# idevicedebuglauncher
**idevicedebuglauncher** is a web service on MacOS that can be used to attach a debugger to a remote application running on an iOS/tvOS device.

This can be used to activate JIT for emulators running on iOS / tvOS ([Provenance](https://provenance-emu.com), [Dolphinios](https://dolphinios.oatmealdome.me), ...).

> **_NOTE:_**   the same functionality is embedded inside the [AltServer](https://altstore.io) so use that instead you have installed your application with AltStore and you just want to enable JIT

![](/doc/app.png) 

Like AltServer, idevicedebuglauncher uses the [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) library to communicate with the devices.

The web service is exposed as Bonjour daemon so that a client can find and ask the service to attach a debugger so that JIT can be enabled.

	// swift code 
	import idevicedebuglauncherlib
		 
	if await idevicedebuglauncherlib().findAndConnect() {
	    print("i'm being debugged")
	}


## Quick install
    $ git clone https://github.com/jeroenwk/idevicedebuglauncher.git
    $ cd idevicedebuglauncher
    $ ./compile && ./install && ./run 

## Run idevicedebuglauncher
- activate the 'Install as system service' switch
- allow to idevicedebuglauncher in the background within the login items preference (only the first time)
- once activate the list of devices is refreshed
- browse to http://localhost:8383/idevice_id by clicking on the link and check for the devices found
- there is a button to pair the AppleTV
- fill in a bundleId to specify the app to be debugged
- click on the blue play icon next to each device to start debugging the app
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

## Deamon configuration
The configuration is stored in:
/System/Volumes/Data/private/var/root/Library/Application\ Support/com.jeroenwk.idevicedebuglauncher/config.plist

The log file is stored in:
/usr/local/var/log/idevicedebuglauncher.log
