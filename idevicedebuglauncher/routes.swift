import PerfectLib
import PerfectHTTP
import Foundation

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
