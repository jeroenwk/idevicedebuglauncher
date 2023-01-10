import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

enum DeviceType: CustomStringConvertible, Codable {
    case usb
    case network
    
    var description: String {
        switch self {
        case.usb:
            return "USB"
        case .network:
            return "Network"
        }
    }
}

struct DeviceInfo: Codable {
    var deviceId: String
    var deviceType: DeviceType
}

func listDevices(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    
    let devices = getDeviceList()
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


func startServer(routes: Routes) {
    /// Inititiate the server on `http://localhost:8181`
    let server = HTTPServer()
    server.addRoutes(routes)
    server.serverPort = 8181
    server.serverAddress = "192.168.1.60"
    
    setDebugLevel(level: 1)
    
    /// Start the serever
    do {
        try server.start()
    } catch {
        print("Network error: \(error)")
    }
}

func getDeviceList() -> [DeviceInfo] {
    var i:Int32 = 0
    var dev_list: UnsafeMutablePointer<idevice_info_t?>? = UnsafeMutablePointer<idevice_info_t?>.allocate(capacity: 0)

    let result:idevice_error_t = idevice_get_device_list_extended(&dev_list, &i)
    
    guard result.rawValue == 0 else {
        Log.error(message: "Unable to retrieve device list!")
        return []
    }
    
    var devices: [DeviceInfo] = []
    
    for n in 0...i-1 {
        guard let dev_list else { return [] }
        guard let info = dev_list[Int(n)] else { return [] }
        guard let deviceId = String(validatingUTF8: info.pointee.udid) else { return [] }
        
        let connectionType = info.pointee.conn_type.rawValue
        
        var deviceInfo: DeviceInfo
        if connectionType == 1 {
            deviceInfo = DeviceInfo(deviceId: deviceId, deviceType: .usb)
        } else {
            deviceInfo = DeviceInfo(deviceId: deviceId, deviceType: .network)
            
        }
        devices.append(deviceInfo)
        Log.info(message: deviceInfo.deviceId + " (" + deviceInfo.deviceType.description + ")")
        
    }
    
    idevice_device_list_extended_free(dev_list)
    
    return devices
}


func setDebugLevel(level: Int) {
    idevice_set_debug_level(Int32(level))
}

/// Define the API routes
var routes = Routes()
routes.add(method: .get, uri: "/idevice_id", handler: listDevices)
routes.add(method: .post, uri: "/post_api", handler: postAPI)

/// Start the server
startServer(routes: routes)
