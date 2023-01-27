#define TOOL_NAME "ideviceinfo"

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

int device_has_mac_address(const char *udid, const char *mac_address)
{
    lockdownd_client_t client = NULL;
    lockdownd_error_t ldret = LOCKDOWN_E_UNKNOWN_ERROR;
    idevice_t device = NULL;
    idevice_error_t ret = IDEVICE_E_UNKNOWN_ERROR;
    int simple = 0;

    const char *key = NULL;
    plist_t node = NULL;


    ret = idevice_new_with_options(&device, udid, IDEVICE_LOOKUP_NETWORK);
    if (ret != IDEVICE_E_SUCCESS) {
        if (udid) {
            fprintf(stderr, "ERROR: Device %s not found!\n", udid);
        } else {
            fprintf(stderr, "ERROR: No device found!\n");
        }
        return -1;
    }

    if (LOCKDOWN_E_SUCCESS != (ldret = simple ?
            lockdownd_client_new(device, &client, TOOL_NAME):
            lockdownd_client_new_with_handshake(device, &client, TOOL_NAME))) {
        fprintf(stderr, "ERROR: Could not connect to lockdownd: %s (%d)\n", lockdownd_strerror(ldret), ldret);
        idevice_free(device);
        return -1;
    }

    /* run query and output information */
    if(lockdownd_get_value(client, NULL, key, &node) == LOCKDOWN_E_SUCCESS) {
        if (node) {
            
            char *mac_value = NULL;
            
            // check wifi
            plist_t wifi_node = plist_dict_get_item(node, "WiFiAddress");
            if (plist_get_node_type(wifi_node) == PLIST_STRING) {
                plist_get_string_val(wifi_node, &mac_value);
            }
            if (mac_value && !strcmp(mac_value, mac_address)) {
                return 1;
            }
            
            // check ethernet
            plist_t eth_node = plist_dict_get_item(node, "EthernetAddress");
            if (plist_get_node_type(eth_node) == PLIST_STRING) {
                plist_get_string_val(eth_node, &mac_value);
            }
            if (mac_value && !strcmp(mac_value, mac_address)) {
                return 1;
            }
            
            if (mac_value) {
                free(mac_value);
            }
            
            plist_free(node);
            node = NULL;
        }
    }

    lockdownd_client_free(client);
    idevice_free(device);

    return 0;
}
