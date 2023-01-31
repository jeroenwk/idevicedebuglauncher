import Swifter

let server = HttpServer()
var bonjour: NetService?
var serverState = ServerState(running: false)

func startServer(port: UInt16) {
    server["/idevice_id"] = listDevices()
    server["/idevicedebug"] = attachDebugger()
    
    serverState.port = port
    do {
        try server.start(port, forceIPv4: true)
        config.preferences.serverPort = port
        serverState.running = true
        logger.info("idevicedebuglauncher started on port \(port)")
        logger.info("register bonjour ...")
        bonjour = NetService(domain: "", type: "_idevicedebuglauncher._tcp.", name: "idevicedebuglauncher", port: Int32(port))
        bonjour?.publish()
    } catch {
        serverState.running = false
        logger.error("error: \(error)")
    }
}

func stopServer() {
    server.stop()
    bonjour?.stop()
    serverState.running = false
    logger.info("idevicedebuglauncher stopped")
}
