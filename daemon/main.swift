import Foundation

let config = Config()
let logger = MultiLogger()

logger.info("starting idevicedebuglauncher daemon ...")

guard CommandLine.arguments.count > 1  else {
    logger.error("No default port specified")
    exit(1)
}

guard let defaultServerPort = UInt16(CommandLine.arguments[1]) else {
    logger.error("Invalid argument given")
    exit(1)
}

logger.info("start listening to xpc commands ...")

listenXpc()

logger.info("try to load port from config ...")
let port = config.preferences.serverPort ?? defaultServerPort

logger.info("starting webserver ...")
startServer(port: port)

logger.info("idevicedebuglauncher daemon started successfully")
dispatchMain()
