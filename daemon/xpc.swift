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
                let command = String(cString: message!)
                
                let reply = xpc_dictionary_create_reply(request)
                
                var response = "unknown command: \(command)"
                
                // TODO: use MessagesEnum istead of strings
                if command == "listDevices" {
                    let devices = LibIMobileDevice.shared.getDeviceList()
                    if let json = json(devices) {
                        if let data = try? JSONSerialization.data(withJSONObject: json) {
                            response = String(data: data, encoding: .utf8) ?? "error while calling \(command)"
                        } else {
                            response = "error while calling \(command)"
                        }
                    } else {
                        response = "error while calling \(command)"
                    }
                }
                
                
                // TODO: use MessagesEnum istead of strings
                if command == "serverState" {
                    let serverState = serverState
                    if let json = json(serverState) {
                        if let data = try? JSONSerialization.data(withJSONObject: json) {
                            response = String(data: data, encoding: .utf8) ?? "error while calling \(command)"
                        } else {
                            response = "error while calling \(command)"
                        }
                    } else {
                        response = "error while calling \(command)"
                    }
                }
                

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
