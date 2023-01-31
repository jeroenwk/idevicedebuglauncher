import Foundation
import debugutils

struct ErrorCode: Codable {
    var code: Int
    var error: String?
}

@available(iOS 13.0.0, *)
public class idevicedebuglauncherlib: ObservableObject {
    @Published public var info = ""
    public init() {}
    
    public func setInfo(_ msg: String) {
        DispatchQueue.main.async {
            self.info = msg
        }
    }
    
    class ServiceDelegate : NSObject, NetServiceDelegate {
        var hostName: String?
        var port: Int?
        
        public func netServiceDidResolveAddress(_ sender: NetService) {
            hostName = sender.hostName!
            port = sender.port
        }
    }
    
    let service = NetService(domain: "local.", type: "_idevicedebuglauncher._tcp.", name: "idevicedebuglauncher")
    let delegate = ServiceDelegate()
    
    var bundleId: String?
    
    public func findService() async -> Bool {
        if isDebugged() != 0 {
            return true
        }
        
        self.setInfo("Start searching for service _idevicedebuglauncher._tcp. ...")
        let timeout = 20
        service.delegate = self.delegate
        service.resolve(withTimeout: Double(timeout))
        
        for _ in 0..<timeout {
            if service.hostName != nil {
                return true
            }
            self.setInfo("searching ...")
            sleep(1)
        }
        self.setInfo("Error: service not found!")
        return false
    }
    
    
    public func findAndConnect() async -> Bool {
        if await findService() {
            do {
                if try await connect() {
                    return true
                }
            } catch {
                self.setInfo("Error: \(error)")
            }
        }
        return false
    }
    
    public func connect() async throws -> Bool {
        if isDebugged() != 0 {
            return true
        }
        
        self.setInfo("Trying to connect to service ...")
        guard let hostName = service.hostName else {
            self.setInfo("No hostname ???")
            return false
        }
        
        guard let url = URL(string: "http://\(hostName):\(service.port)/idevicedebug?bundleId=" + Bundle.main.bundleIdentifier!) else {
            return false
        }
        
        self.info = "Try to attach debugger via url: \(url)"
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        self.info = String(bytes: data, encoding: String.Encoding.utf8) ?? ""
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(ErrorCode.self, from: data)
        if result.code == 0 {
            return true
        } else {
            print("Error: could not attach debugger. Error code: \(result.code) \(result.error ?? "")")
        }
        
        return false
    }
}

