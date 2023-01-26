import SwiftUI
import ServiceManagement

struct ContentView: View {
    // daemon state
    @State private var installed = false
    @State private var notAllowed = false
    
    // server state
    @State private var serverState = ServerState(running: false)
    
    // ui
    @State private var devices: [DeviceInfo] = []
    @State private var port = ""
    
    
    func updateServerState(from command: Command, with payload: Codable? = nil) {
        Commands.send(command, payload: payload) { response in
            if let state = response as? ServerState {
                self.serverState = state
                if let p = serverState.port {
                    self.port = String(p)
                }
            }
        }
    }
    
    func updateDevices() {
        Commands.send(.LIST_DEVICES) { response in
            if let devices = response as? [DeviceInfo] {
                self.devices = devices
            }
        }
    }
    
    func stopServer() {
        updateServerState(from: .STOP_SERVER)
    }
    
    func startServer(port: UInt16?) {
        updateServerState(from: .START_SERVER, with: port)
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
                        serverState.running ? stopServer() : startServer(port: UInt16(port))
                    } label: {
                        Text(serverState.running ? "Stop Server" : "Start Server")
                            .padding(20)
                    }
                    Button {
                        updateDevices()
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
                        updateServerState(from: .GET_SERVER_STATE)
                        updateDevices()
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
