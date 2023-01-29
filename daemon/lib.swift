import Foundation

class LibIMobileDevice {
    
    typealias Callback = @convention(c) (
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<Int8>?,
        UnsafeMutablePointer<UInt32>?
    ) -> Void
        
    var pairingInfo = PairingInfo()
    
    func pairAppleTV() -> ErrorCode {
        self.pairingInfo = PairingInfo()
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        let callback: Callback =  { context, pin, size in
            guard let context else {
                logger.error("no context to set pincode")
                return
            }
            let lib = Unmanaged<LibIMobileDevice>.fromOpaque(context).takeUnretainedValue()
            
            for n in 0..<PAIRING_TIMEOUT_SECONDS {
                if lib.pairingInfo.pin.count == PINCODE_SIZE {
                    break
                }
                sleep(1)
                if n == 29 {
                    lib.pairingInfo.errorCode = ErrorCode(code: 1, error: "timed out waiting for pincode")
                    return
                }
            }
            
            let bytes:[Int8] = lib.pairingInfo.pin.utf8.map{Int8(bitPattern: $0)}
            let a = UnsafeMutableBufferPointer(start: pin, count: bytes.count)
            for i in 0..<bytes.count {
                a[i] = bytes[i]
            }
            size?.pointee = UInt32(PINCODE_SIZE)
        }
        
        let err = pair(context, callback)
        if err > 0 {
            if pairingInfo.errorCode.code > 0 {
                return pairingInfo.errorCode
            }
            return ErrorCode(code:Int(err), error: "pairing failed")
        } else {
            return ErrorCode(code: 0)
        }
    }
    
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
