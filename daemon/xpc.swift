import Foundation

let listener = xpc_connection_create_mach_service("com.xpc.idevicedebuglauncher.sendcommand", nil, UInt64(XPC_CONNECTION_MACH_SERVICE_LISTENER))

func listenXpc() {
    xpc_connection_set_event_handler(listener) { peer in
        if xpc_get_type(peer) != XPC_TYPE_CONNECTION {
            return
        }
        xpc_connection_set_event_handler(peer) { request in
            if xpc_get_type(request) == XPC_TYPE_DICTIONARY {
                let message = xpc_dictionary_get_string(request, "MessageKey")
                let encodedMessage = String(cString: message!)
                let reply = xpc_dictionary_create_reply(request)
                let response = "\(encodedMessage)"
                response.withCString { rawResponse in
                    xpc_dictionary_set_string(reply!, "ResponseKey", rawResponse)
                }
                xpc_connection_send_message(peer, reply!)
            }
        }
        xpc_connection_activate(peer)
    }
    
    xpc_connection_activate(listener)
}
