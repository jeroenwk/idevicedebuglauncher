import SwiftUI
import ServiceManagement

struct ContentView: View {
    // service state
    @State private var installed = false
    @State private var notAllowed = false
    
    // server state
    @State private var serverState = ServerState(running: false)
    @State private var port = ""
    
    @State private var devices: [DeviceInfo] = []
    
    
    func stopServer() {
        
    }
    
    func startServer() {
        
    }
    
    func updateServerState() {
        let ret = Commands.send("serverState")
        if let data = ret.data(using: .utf8) {
            if let state = try? JSONDecoder().decode(ServerState.self, from: data) {
                serverState = state
                if let p = serverState.port {
                    port = String(p)
                }
            }
        }
    }
    
    func getDevices() -> [DeviceInfo] {
        let ret = Commands.send("listDevices")
        if let data = ret.data(using: .utf8) {
            if let devices = try? JSONDecoder().decode([DeviceInfo].self, from: data) {
                return devices
            }
        }
        return []
    }
    
    var body: some View {
        
        HStack {
            Image("logo")
                .padding(.trailing, 20)
            VStack(alignment: .leading) {
                
                HStack {
                    Toggle(isOn: $installed) {
                        Text("Install as system service")
                    }
                    .toggleStyle(.switch)
                    if notAllowed {
                        Text("Please allow idevicedebuglauncher in the Background")
                            .foregroundColor(.red)
                    } else {
                        Spacer()
                        Text("on port:")
                        TextField("port number", text: $port)
                    }
                }
                
                HStack {
                    Text("Status: ")
                    Label(serverState.running ? "on" : "off", systemImage: "circle.fill")
                        .foregroundColor(serverState.running ? .green : .red)
                    if serverState.running {
                        Link("http://localhost:\(port)/idevice_id/", destination: URL(string: "http://localhost:\(port)/idevice_id/")!)
                    }
                }
                
                Divider()
                
                HStack {
                    Button {
                        DispatchQueue.global(qos: .userInitiated).async {
                            serverState.running ? stopServer() : startServer()
                        }
                    } label: {
                        Text(serverState.running ? "Stop Server" : "Start Server")
                            .padding(20)
                    }
                    Button {
                        DispatchQueue.global(qos: .userInitiated).async {
                            devices = getDevices()
                        }
                    } label: {
                        Text("Refresh devices")
                            .padding(20)
                    }
                    Button {
                        //Commands.send("pair")
                    } label: {
                        Text("Pair Apple TV")
                            .padding(20)
                    }
                }
                
                Text("Devices")
                    .font(.headline)
                
                Table(devices) {
                    TableColumn("Id", value: \.deviceId)
                    TableColumn("Type") { device in
                        Label(device.deviceType.description, systemImage: device.deviceType.icon)
                    }
                }
            }
        }
        .padding()
        .onChange(of: installed) { newValue in
            DispatchQueue.global(qos: .userInitiated).async {
                if newValue {
                    let registered = Commands.register()
                    let status = Commands.status()
                    if !registered && (
                        status == .requiresApproval ||
                        status == .notFound ) {
                        installed = false
                        notAllowed = true
                        logger.warning("Can't register daemon \(status.rawValue)")
                        SMAppService.openSystemSettingsLoginItems()
                    } else {
                        notAllowed = false
                        updateServerState()
                        devices = getDevices()
                    }
                } else {
                    serverState = ServerState(running: false)
                    Commands.unregister()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
