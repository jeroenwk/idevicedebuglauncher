# idevicedebuglauncherlib

idevicedebuglauncherlib is a small helper package that allows an app to request being debugged by idevicedebuglauncher

    if await idevicedebuglauncherlib().findAndConnect() {
        print("i'm being debugged")
    }
