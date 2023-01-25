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
    
    var icon: String {
        switch self {
        case.usb:
            return "cable.connector"
        case .network:
            return "network"
        }
    }
}

struct DeviceInfo: Codable, Identifiable {
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
