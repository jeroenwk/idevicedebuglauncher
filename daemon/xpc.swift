import Foundation

let listener = xpc_connection_create_mach_service("com.xpc.idevicedebuglauncher.sendcommand", nil, UInt64(XPC_CONNECTION_MACH_SERVICE_LISTENER))
let lib = LibIMobileDevice()

func executeCommand(_ command: Command, payloadString: String? = nil) -> Codable {
    var payload: Any?
    if let payloadString, let payloadType = command.payloadType as? Decodable.Type {
        payload = fromJson(str: payloadString, type: payloadType)
    }
    
    switch command {
    case .LIST_DEVICES:
        return lib.getDeviceList()
    case .GET_DEVICE_INFO:
        if let request = payload as? DeviceInfoRequest {
            return lib.deviceInfo(for: request.udid, with: request.fields)
        }
    case .START_SERVER:
        if let port = payload as? UInt16 {
            startServer(port: port)
        }
    case .STOP_SERVER:
        stopServer()
    case .APPLETV_PAIR:
        return lib.pairAppleTV()
    case .GET_SERVER_STATE:
        break
    case .SET_PIN:
        if let pincode = payload as? String {
            lib.pairingInfo.pin = pincode
        }
        return ErrorCode(code: 0)
    }
    return serverState
}

func listenXpc() {
    lib.setDebugLevel(level: 1)
    
    xpc_connection_set_event_handler(listener) { peer in
        if xpc_get_type(peer) != XPC_TYPE_CONNECTION {
            return
        }
        xpc_connection_set_event_handler(peer) { request in
            if xpc_get_type(request) == XPC_TYPE_DICTIONARY {
                let commandString = xpc_dictionary_get_string(request, "Command")
                
                var response = "unknown command: \(String(describing: commandString))"
                let reply = xpc_dictionary_create_reply(request)
                
                if let command = Command(rawValue: String(cString: commandString!)) {
                    
                    let payloadString = xpc_dictionary_get_string(request, "Payload")

                    if let json = json(executeCommand(command, payloadString: (payloadString != nil) ?
                                                      String(cString: payloadString!) : nil)) {
                        if let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed) {
                            response = String(data: data, encoding: .utf8) ?? "error while calling \(command)"
                        } else {
                            response = "error while calling \(command)"
                        }
                    } else {
                        response = "error while calling \(command)"
                    }
                }

                response.withCString { raw in
                    xpc_dictionary_set_string(reply!, "Response", raw)
                }
                xpc_connection_send_message(peer, reply!)
            }
        }
        xpc_connection_activate(peer)
    }
    
    xpc_connection_activate(listener)
}
