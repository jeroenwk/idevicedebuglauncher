import PerfectLib
import PerfectHTTP
import Foundation

let routes = Routes([
    Route(method: .get, uri: "/idevice_id", handler: listDevices),
    Route(method: .get, uri: "/idevicedebug", handler: connectDebugger)
])

struct ConnectDebuggerResponse: Codable {
    var error: Int
}

func connectDebugger(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    
    var r = ConnectDebuggerResponse(error: -1)
    let queryParams = request.queryParams
    let ipAddress = request.remoteAddress.host
    
    let udid = queryParams.first(where: {
        $0.0 == "udid"
    })?.1 ?? lib.udidFromIpAddress(ipAddress: ipAddress)

    guard let udid else {
        Log.error(message: "No udid found!")
        _ = try? response.setBody(json: r)
        response.completed()
        return
    }

    guard let bundleId = queryParams.first(where: { $0.0 == "bundleId" })?.1 else {
        Log.error(message: "No bundleId given!")
        _ = try? response.setBody(json: r)
        response.completed()
        return
    }
    
    Log.info(message: "Starting debugger on " + udid + " " + bundleId + "...")
    let error = lib.connectDebugger(udid: udid, bundleId: bundleId)
    if error == 0 {
        Log.info(message: "Debugger has been launched in background")
    }
    r.error = error
    
    _ = try? response.setBody(json: r)
    response.completed()
}

func listDevices(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    
    let devices = lib.getDeviceList()
    guard let json = try? JSONEncoder().encode(devices) else {
        Log.error(message: "Cannot convert device list to json!")
        return
    }
        
    _ = try? response.setBody(json: String(data: json, encoding: .utf8)!)
    response.completed()
}

func postAPI(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    let body = request.postBodyString
    let json = try? body?.jsonDecode() as? [String:Any]
    let name = json?["input"] as? String ?? "Undefined"
    
    _ = try? response.setBody(json: ["input": name])
    response.completed()
}
