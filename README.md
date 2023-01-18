## idevicedebuglauncher
idevicedebuglauncher is a simple deamon on macos that can attach a debugger to an application on an iOS/tvOS device.
This can be used to activate JIT on emulators running on the Apple TV (Provenance, Dolphinios, ...)

#### Install libimobiledevice from source
- brew install pkg-config openssl@3 autoconf automake libtool libplist libusbmuxd
- export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig" (use brew info openssl to find out the exact path)
- git submodule update --init --recursive
- cd externals/libimobiledevice-glue
- ./autogen.sh && make && sudo make install (if complaining on ltmain.sh, just run the commands again)
- cd ../../externals/libimobiledevice
- ./autogen.sh && make && sudo make install (if complaining on ltmain.sh, just run the commands again)

#### Build
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
