import Swifter

let server = HttpServer()

func startServer() {
    server["/idevice_id"] = listDevices()
    server["/idevicedebug"] = connectDebugger()
    
    do {
        try server.start(serverPort, forceIPv4: true)
        logger.info("idevicedebuglauncher started on port \(serverPort)")
    } catch {
        logger.error("error: \(error)")
    }
}
