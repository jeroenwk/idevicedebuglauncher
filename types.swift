import Foundation

typealias PortNumber = UInt16

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
        return deviceId + "-" + deviceType.description
    }
    var deviceId: String
    var deviceType: DeviceType
}

struct ServerState: Codable {
    var running: Bool
    var port: UInt16?
}

struct ErrorCode: Codable {
    var code: UInt16
    var error: String?
}

enum Command: String {
    case LIST_DEVICES = "listDevices"
    case START_SERVER = "startServer"
    case STOP_SERVER = "stopServer"
    case GET_SERVER_STATE = "serverState"
    case APPLETV_PAIR = "appleTVPair"
    
    var resultType: Decodable.Type {
        switch self {
        case .LIST_DEVICES:
            return [DeviceInfo].self
        case .APPLETV_PAIR:
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
        case .STOP_SERVER:
            break
        case .GET_SERVER_STATE:
            break
        case .APPLETV_PAIR:
            break
        }
        return nil
    }
}
