import Foundation
import ServiceManagement
import XPCOverlay

class Commands {
    class func register() {
        let service = SMAppService.daemon(plistName: "com.jeroenwk.idevicedebuglauncher.plist")

        do {
            try service.register()
            logger.info("Successfully registered \(service)")
        } catch {
            logger.error("Unable to register \(error)")
        }
    }

    class func unregister() {
        let service = SMAppService.daemon(plistName: "com.jeroenwk.idevicedebuglauncher.plist")

        do {
            try service.unregister()
            logger.info("Successfully unregistered \(service)")
        } catch {
            logger.error("Unable to unregister \(error)")
        }
    }

    class func status() -> SMAppService.Status {
        let service = SMAppService.daemon(plistName: "com.jeroenwk.idevicedebuglauncher.plist")
        //logger.info("\(service.description) has status \(service.status.rawValue)")
        return service.status
    }
    
    class func send(_ command: Command, payload: Codable? = nil, _ completion: @escaping (_ response: Any?)->()) {
        Task.detached {
            let request = xpc_dictionary_create_empty()
            
            let commandString = command.rawValue
            commandString.withCString { raw in
                xpc_dictionary_set_string(request, "Command", raw)
            }
            
            if let payload {
                guard let json = json(payload) else {
                    logger.error("Can't encode payload")
                    return
                }
                if let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed) {
                    if let payloadString = String(data: data, encoding: .utf8) {
                        payloadString.withCString { raw in
                            xpc_dictionary_set_string(request, "Payload", raw)
                        }
                    }
                }
            }

            var error: xpc_rich_error_t? = nil
            let session = xpc_session_create_mach_service("com.xpc.idevicedebuglauncher.sendcommand", nil, .none, &error)
            if let error {
                logger.error("Unable to create xpc_session \(error.description)")
                return
            }
            
            let reply = xpc_session_send_message_with_reply_sync(session!, request, &error)
            if let error = error {
                logger.error("Error sending message \(error.description)")
                return
            }
            
            let responseData = xpc_dictionary_get_string(reply!, "Response")
            let encodedResponse = String(cString: responseData!)
            let response = fromJson(str: encodedResponse, type: command.resultType)
            
            xpc_session_cancel(session!)
            DispatchQueue.main.async {
                completion(response)
            }
            
        }
    }
    
}
