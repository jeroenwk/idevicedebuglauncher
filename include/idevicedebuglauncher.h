#ifndef idevicedebuglauncher_h
#define idevicedebuglauncher_h

#define HAVE_OPENSSL 1

typedef void (*pin_cb_t) (void *context, char* data_ptr, unsigned int* data_size);

int start_server(int argc, char** argv);
int device_has_mac_address(const char *udid, const char *mac_address);
int pair(void* context, pin_cb_t callback);

int callbackTest(void* context, pin_cb_t callback);

#endif
