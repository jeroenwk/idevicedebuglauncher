import Foundation
import os.log

class MultiLogger {
    class StandardError: TextOutputStream {
      func write(_ string: String) {
        try! FileHandle.standardError.write(contentsOf: Data(string.utf8))
      }
    }
    class StandardOutput: TextOutputStream {
      func write(_ string: String) {
          try! FileHandle.standardOutput.write(contentsOf: Data(string.utf8))
      }
    }
    
    let logger = Logger(subsystem: "com.jeroenwk.idevicedebuglauncher.daemon", category: "debugging")
    var standardError = StandardError()
    var standardOutput = StandardOutput()
    
    public func info(_ message: String) {
        logger.info("\(message)")
        print(message, to: &standardOutput)
    }
    public func error(_ message: String) {
        logger.error("\(message)")
        print(message, to: &standardError)
    }
}
