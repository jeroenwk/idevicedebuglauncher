import Foundation

class LibIMobileDevice {
    static let shared = LibIMobileDevice()
    
    func udidFromIpAddress(ipAddress : String) -> String? {
        guard let mac = ARP.walkMACAddress(of: ipAddress) else {
            logger.error("Unable to retrieve MAC from \(ipAddress)")
            return nil
        }

        let devices = getDeviceList()
        for device in devices {
            let udid = device.deviceId
            if device_has_mac_address(udid.toUnsafePointer(), mac.toUnsafePointer()) != 0 {
                return udid
            }
        }
        return nil
    }

    func connectDebugger(udid: String, bundleId: String) -> Int {
        let args = ["", "-n", "--detach", "-u", udid , "run", bundleId]

        // Create [UnsafeMutablePointer<Int8>]:
        var cargs = args.map { strdup($0) }
        // Call C function:
        let result = start_server(Int32(args.count), &cargs)
        // Free the duplicated strings:
        
        for ptr in cargs { free(ptr) }
        return Int(result)
    }

    func getDeviceList() -> [DeviceInfo] {
        var i:Int32 = 0
        var dev_list: UnsafeMutablePointer<idevice_info_t?>? = UnsafeMutablePointer<idevice_info_t?>.allocate(capacity: 0)

        let result:idevice_error_t = idevice_get_device_list_extended(&dev_list, &i)
        
        guard result.rawValue == 0 else {
            logger.error("Unable to retrieve device list!")
            return []
        }

        var devices: [DeviceInfo] = []
        
        for n in 0..<i {
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
            logger.info("\(deviceInfo.deviceId) (\(deviceInfo.deviceType.description)")
            
        }
        
        idevice_device_list_extended_free(dev_list)
        
        logger.info("getDeviceList: Found \(devices.count) devices")
        return devices
    }

    func setDebugLevel(level: Int) {
        idevice_set_debug_level(Int32(level))
    }
}
