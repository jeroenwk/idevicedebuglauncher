#define TOOL_NAME "idevicepair"

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <getopt.h>
#ifndef WIN32
#include <signal.h>
#endif

#include "../include/libimobiledevice.h"
#include "../include/plist.h"
#include "../include/lockdown.h"
#include "../include/idevicedebuglauncher.h"


void* context;
pin_cb_t callback;

static void pairing_cb(lockdownd_cu_pairing_cb_type_t cb_type, void *user_data, void* data_ptr, unsigned int* data_size)
{
    if (cb_type == LOCKDOWN_CU_PAIRING_PIN_REQUESTED) {

        callback(context, data_ptr, data_size);
        
    } else if (cb_type == LOCKDOWN_CU_PAIRING_ERROR) {
        printf("ERROR: %s\n", (data_ptr) ? (char*)data_ptr : "(unknown)");
    }
}

int pair(void* ctx, pin_cb_t cb)
{
    lockdownd_client_t client = NULL;
    idevice_t device = NULL;
    idevice_error_t ret = IDEVICE_E_UNKNOWN_ERROR;
    lockdownd_error_t lerr;
    int result;
    char *type = NULL;
    plist_t host_info_plist = NULL;
    char *udid = NULL;
    
    context = ctx;
    callback = cb;
    
    ret = idevice_new_with_options(&device, udid, IDEVICE_LOOKUP_NETWORK);
    if (ret != IDEVICE_E_SUCCESS) {
        if (udid) {
            printf("No device found with udid %s.\n", udid);
        } else {
            printf("No device found.\n");
        }
        result = EXIT_FAILURE;
        goto leave;
    }
    if (!udid) {
        ret = idevice_get_udid(device, &udid);
        if (ret != IDEVICE_E_SUCCESS) {
            printf("ERROR: Could not get device udid, error code %d\n", ret);
            result = EXIT_FAILURE;
            goto leave;
        }
    }
    
    lerr = lockdownd_client_new(device, &client, TOOL_NAME);
    if (lerr != LOCKDOWN_E_SUCCESS) {
        printf("ERROR: Could not connect to lockdownd, error code %d\n", lerr);
        result = EXIT_FAILURE;
        goto leave;
    }
    
    result = EXIT_SUCCESS;
    
    lerr = lockdownd_query_type(client, &type);
    if (lerr != LOCKDOWN_E_SUCCESS) {
        printf("QueryType failed, error code %d\n", lerr);
        result = EXIT_FAILURE;
        goto leave;
    } else {
        if (strcmp("com.apple.mobile.lockdown", type) != 0) {
            printf("WARNING: QueryType request returned '%s'\n", type);
        }
        free(type);
    }
    
    
    lerr = lockdownd_cu_pairing_create(client, pairing_cb, NULL, host_info_plist, NULL);
    if (lerr == LOCKDOWN_E_SUCCESS) {
        lerr = lockdownd_pair_cu(client);
        printf("SUCCESS: Paired with device %s\n", udid);
    } else {
        result = EXIT_FAILURE;
        printf("ERROR: Can't pair with device %s\n", udid);
    }
    
    
    
leave:
    lockdownd_client_free(client);
    idevice_free(device);
    free(udid);
    //free(context);

    return result;
}


