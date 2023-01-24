import Foundation
import os.log

let logger = Logger(subsystem: "com.jeroenwk.idevicedebuglauncher", category: "debugging")

logger.info("starting idevicedebuglauncher daemon ...")

let serverPort = UInt16(CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "") ?? UInt16(8181)

logger.info("initializing libimobiledevice ...")
let lib = LibIMobileDevice.shared
lib.setDebugLevel(level: 1)

logger.info("start listening to xpc commands ...")
listenXpc()

logger.info("starting webserver ...")
startServer()

logger.info("idevicedebuglauncher daemon started successfully")
dispatchMain()
