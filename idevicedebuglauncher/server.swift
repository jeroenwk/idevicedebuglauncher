import Swifter
import Dispatch

let server = HttpServer()

func startServer() {
    let semaphore = DispatchSemaphore(value: 0)
    
    server["/idevice_id"] = listDevices()
    server["/idevicedebug"] = connectDebugger()
    
    do {
        try server.start(serverPort, forceIPv4: true)
        logger.info("idevicedebuglauncher started on port \(serverPort)")
        semaphore.wait()
    } catch {
        logger.error("error: \(error)")
        semaphore.signal()
    }
}
