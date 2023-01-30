import Foundation
import Swifter

struct ConnectDebuggerResponse: Codable {
    var error: Int
}

func badRequest(_ err_msg: String) -> HttpResponse {
    logger.error("\(err_msg)")
    return .badRequest(.text(err_msg))
}

func listDevices() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        let lib = LibIMobileDevice()
        lib.setDebugLevel(level: 1)
        let devices = lib.getDeviceList()
        guard let json = json(devices) else {
            return badRequest("Cannot convert device list to json!")
        }
        return .ok(.json(json))
    }
}

func connectDebugger() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        var r = ConnectDebuggerResponse(error: -1)
        let queryParams = request.queryParams
        
        guard var ipAddress = request.address else {
            return badRequest("Can't get ip address from caller")
        }
        
        if let customIpAddress = queryParams.first(where: { $0.0 == "ip" })?.1 {
            ipAddress = customIpAddress
        }
        
        let lib = LibIMobileDevice()
        lib.setDebugLevel(level: 1)
        
        let udid = queryParams.first(where: {
            $0.0 == "udid"
        })?.1 ?? lib.udidFromIpAddress(ipAddress: ipAddress)
        
        guard let udid else {
            return badRequest("No udid found!")
        }
        
        guard let bundleId = queryParams.first(where: { $0.0 == "bundleId" })?.1 else {
            return badRequest("No bundleId given!")
        }
        
        logger.info("Starting debugger on \(udid) \(bundleId) ...")
        let error = lib.connectDebugger(udid: udid, bundleId: bundleId)
        if error == 0 {
            logger.info("Debugger has been launched in background")
        }
        r.error = error
        
        guard let json = json(r) else {
            return badRequest("Invalid response from debugger!")
        }
        
        return .ok(.json(json))
    }
}


