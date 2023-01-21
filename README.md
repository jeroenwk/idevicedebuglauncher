# idevicedebuglauncher
idevicedebuglauncher is a simple deamon on macos that can attach a debugger to an application on an iOS/tvOS device.
This can be used to activate JIT on emulators running on the Apple TV (Provenance, Dolphinios, ...)


## Build idevicedebuglauncher
- open idevicedebuglauncher.xcodeproj
- build & run (you need to run the project in order to install later)
- browse to http://localhost:8080/idevice_id and check for the devices found (Note: the port nb can be given as launch argument)
- stop

## Compile & install universal libraries
This step is optional because the repository includes already precompiled binaries for MacOS arm64 and x86_64 architectures:
- openssl: libcrypto-3.0.7, libssl-3.0.7
- libplist: libplist-2.2.0
- libusbmuxd: libusbmuxd-2.0.6
- libimobiledevice: libimobiledevice-1.3.0

 To make sure everything is working on your specific device or if you want to use newer versions of the libraries, a script can be used to re-compile them.
 
 The script basicly does the following:
 - cleans a tmp directory if already used before
 - checks out the libraries and initializes them as git submodules
 - for each library it cleans, compiles and installs into a tmp directory
 - updates the rpaths so that all libraries can be installed next to each other in whatever location
 - copies the library inside the libs directory for the current architecture
 - included the library into a universal library

### steps
- make sure you have the automake tools installed.

        $ brew install pkg-config autoconf automake libtool
- Run the script 'install_libs.sh' inside its own directory.

        $ ./install_libs.sh

## Install daemon
run ./install.sh script to install daemon
This will install an excecutable (daemon) 'idevicedebuglauncher' in /usr/local/bin and the launchd configuration file com.jeroenwk.idevicedebuglauncher.plist in /Library/LaunchDaemons/

### Run daemon
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
curl http://localhost:8080/idevice_id -w "\n\n\n"
curl http://localhost: 8080/idevicedebug\?bundleId=com.jeroenwk.provenance -w "\n\n\n"

### Apple TV
#### pairing
- idevicepair -w pair
- after pairing note the udid of the Apple TV

#### debug
idevicedebug -n -u bbc1630faa46f5acb41938898ef7b26e912f9bf8 run com.jeroenwk.provenance
