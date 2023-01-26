import Foundation

class Config {
    let url: URL?
    let bundleIdentifier = "com.jeroenwk.idevicedebuglauncher" //FIXME: use compiler flag?
    
    var preferences = Preferences() {
        didSet {
            save()
        }
    }
 
    struct Preferences: Codable {
        var serverPort: UInt16?
    }
    
    init() {
        if let dir = try? URL(for: .applicationSupportDirectory, in: .allDomainsMask, create: true)
            .appendingPathComponent(bundleIdentifier) {
            
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            url = dir.appendingPathComponent("config.plist")
        } else {
            url = nil
        }

        load()
    }
    
    func load() {
        guard let url else {
            return
        }
        if let data = try? Data(contentsOf: url) {
            do {
                let decoder = PropertyListDecoder()
                self.preferences = try decoder.decode(Preferences.self, from: data)
            } catch {
                print(error)
                logger.error("can't load configuration")
            }
        }
    }
    
    func save() {
        guard let url else {
            return
        }
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(preferences)
            try data.write(to: url, options: .atomic)
        } catch {
            print(error)
            logger.error("can't save configuration")
        }
    }
}
