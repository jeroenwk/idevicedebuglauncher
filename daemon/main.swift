import Foundation
import os.log

let logger = Logger(subsystem: "com.jeroenwk.idevicedebuglauncher", category: "debugging")
let serverPort = UInt16(CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "") ?? UInt16(8080)

let lib = LibIMobileDevice.shared
lib.setDebugLevel(level: 1)

startServer()

