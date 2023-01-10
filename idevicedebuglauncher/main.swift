import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let serverAddress = "192.168.1.60"
let serverPort = 8181

let lib = LibIMobileDevice.shared

var routes = Routes()
routes.add(method: .get, uri: "/idevice_id", handler: listDevices)
//routes.add(method: .post, uri: "/post_api", handler: postAPI)

lib.setDebugLevel(level: 1)
startServer(routes: routes)
