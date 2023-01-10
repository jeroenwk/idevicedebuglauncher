import PerfectHTTP
import PerfectHTTPServer

func startServer() {
    let server = HTTPServer()
    server.addRoutes(routes)
    server.serverPort = UInt16(serverPort)
    server.serverAddress = serverAddress
    
    do {
        try server.start()
    } catch {
        print("Network error: \(error)")
    }
}
