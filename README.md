## idevicedebuglauncher
idevicedebuglauncher is a simple deamon on macos that can attach a debugger to an application on an iOS/tvOS device.
This can be used to activate JIT on emulators running on the Apple TV (Provenance, Dolphinios, ...)

#### Build
- brew install libimobiledevice
- change ip address and port in idevicedebuglauncher/main.js
- open idevicedebuglauncher.xcodeproj
- build & run (you need to run it in order to install)
- browse to http://[ipaddress]:[port]/idevice_id and check for the devices found
- stop

#### Build
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
curl http://192.168.1.60:8181/idevice_id -w "\n\n\n"
