import Foundation
import ServiceManagement
import XPCOverlay

class Commands {
    class func register() -> Bool {
        let service = SMAppService.daemon(plistName: "com.jeroenwk.idevicedebuglauncher.plist")

        do {
            try service.register()
            logger.info("Successfully registered \(service)")
            return true
        } catch {
            logger.error("Unable to register \(error)")
        }
        
        return false
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
        logger.info("\(service.description) has status \(service.status.rawValue)")
        return service.status
    }
    
    class func send(_ message: String) {
        let request = xpc_dictionary_create_empty()
        message.withCString { rawMessage in
            xpc_dictionary_set_string(request, "MessageKey", rawMessage)
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

        let response = xpc_dictionary_get_string(reply!, "ResponseKey")
        let encodedResponse = String(cString: response!)

        logger.info("Received \"\(encodedResponse)\"")

        xpc_session_cancel(session!)
    }
}
