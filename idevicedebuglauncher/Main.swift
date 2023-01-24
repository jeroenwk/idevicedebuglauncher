import SwiftUI
import os.log

let logger = Logger(subsystem: "com.jeroenwk.idevicedebuglauncher", category: "debugging")

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
