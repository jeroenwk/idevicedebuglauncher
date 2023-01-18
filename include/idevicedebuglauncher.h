#ifndef idevicedebuglauncher_h
#define idevicedebuglauncher_h

int start_server(int argc, char** argv);
int device_has_mac_address(const char *udid, const char *mac_address);

#endif
