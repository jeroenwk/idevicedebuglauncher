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
