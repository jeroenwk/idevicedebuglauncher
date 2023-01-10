import Foundation
import PerfectLib

class LibIMobileDevice {
    static let shared = LibIMobileDevice()
    
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
}
