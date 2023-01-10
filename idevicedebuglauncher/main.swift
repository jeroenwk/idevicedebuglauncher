import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let serverAddress = "192.168.1.60"
let serverPort = 8181

let lib = LibIMobileDevice.shared

lib.setDebugLevel(level: 1)
startServer()
