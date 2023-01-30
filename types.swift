import Foundation

typealias PortNumber = UInt16
typealias PinCode = String
typealias UDid = String

public let PINCODE_SIZE = 6
public let PAIRING_TIMEOUT_SECONDS = 60

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
    
    var icon: String {
        switch self {
        case.usb:
            return "cable.connector"
        case .network:
            return "network"
        }
    }
}

struct DeviceInfo: Codable, Identifiable, Equatable {
    var id: String {
        return deviceId + "-" + (deviceType?.description ?? "")
    }
    var deviceId: String
    var deviceType: DeviceType?
    var extraInfo: [String:String]?
}

struct DeviceInfoRequest: Codable, Equatable {
    var udid: String
    var fields: [String]
}

struct PairingInfo {
    var pin = ""
    var errorCode = ErrorCode(code: 0)
}

struct ServerState: Codable {
    var running: Bool
    var port: UInt16?
}

struct ErrorCode: Codable {
    var code: Int
    var error: String? {
        didSet {
            if let error {
                logger.error("Error: \(error)")
            }
        }
    }
}

enum Command: String {
    case LIST_DEVICES = "listDevices"
    case GET_DEVICE_INFO = "deviceInfo"
    case START_SERVER = "startServer"
    case STOP_SERVER = "stopServer"
    case GET_SERVER_STATE = "serverState"
    case APPLETV_PAIR = "appleTVPair"
    case SET_PIN = "setPinCode"
    
    var resultType: Decodable.Type {
        switch self {
        case .LIST_DEVICES:
            return [DeviceInfo].self
        case .GET_DEVICE_INFO:
            return DeviceInfo.self
        case .APPLETV_PAIR:
            return ErrorCode.self
        case .SET_PIN:
            return ErrorCode.self
        case .START_SERVER:
            break
        case .STOP_SERVER:
            break
        case .GET_SERVER_STATE:
            break
        }
        return ServerState.self
    }
    
    var payloadType: Encodable.Type? {
        switch self {
        case .START_SERVER:
            return PortNumber.self
        case .LIST_DEVICES:
            break
        case .GET_DEVICE_INFO:
            return UDid.self
        case .STOP_SERVER:
            break
        case .GET_SERVER_STATE:
            break
        case .APPLETV_PAIR:
            break
        case .SET_PIN:
            return PinCode.self
        }
        return nil
    }
}
