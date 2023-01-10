import PerfectLib
import PerfectHTTP
import Foundation

let routes = Routes([
    Route(method: .get, uri: "/idevice_id", handler: listDevices),
    Route(method: .get, uri: "/idevicedebug", handler: connectDebugger)
])

func connectDebugger(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    
    let queryParams = request.queryParams
    guard let udid = queryParams.first(where: { $0.0 == "udid" })?.1 else {
        Log.error(message: "No udid given!")
        return
    }
    guard let bundleId = queryParams.first(where: { $0.0 == "bundleId" })?.1 else {
        Log.error(message: "No bundleId given!")
        return
    }
    
    let result = lib.connectDebugger(udid: udid, bundleId: bundleId)
    
    _ = try? response.setBody(json: ["error code:": result])
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
    
    _ = try? response.setBody(json: ["input:":name])
    response.completed()
}
