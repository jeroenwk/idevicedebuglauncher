import Swifter

let server = HttpServer()
var serverState = ServerState(running: false)

func startServer(port: UInt16) {
    server["/idevice_id"] = listDevices()
    server["/idevicedebug"] = connectDebugger()
    
    serverState.port = port
    do {
        try server.start(port, forceIPv4: true)
        serverState.running = true
        logger.info("idevicedebuglauncher started on port \(port)")
        logger.info("register bonjour ...")
        let bonjour = NetService(domain: "", type: "_idevicedebuglauncher._tcp.", name: "idevicedebuglauncher", port: Int32(port))
        bonjour.publish()
    } catch {
        serverState.running = false
        logger.error("error: \(error)")
    }
}

func stopServer() {
    server.stop()
    serverState.running = true
    logger.info("idevicedebuglauncher stopped")
}
