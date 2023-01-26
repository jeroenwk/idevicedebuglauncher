import SwiftUI
import ServiceManagement

struct ContentView: View {
    @State private var serviceState = SMAppService.Status(rawValue: 0)
    @State private var serverState = ServerState(running: false)
    
    // ui
    @State private var installRequested = false
    @State private var devices: [DeviceInfo] = []
    @State private var port = ""
    @State private var isPairing = false
    @ObservedObject private var code = OTPModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func getServiceState() {
        self.serviceState = Commands.status()
        updateServiceState()
    }
    
    func validateCode() {
        
    }
    
    func updateServiceState() {
        if self.serviceState == .requiresApproval {
            installRequested = true
            self.serverState = ServerState(running: false)
            SMAppService.openSystemSettingsLoginItems()
        }
        
        if self.serviceState == .notRegistered {
            self.serverState = ServerState(running: false)
            installRequested = false
        }
        
        if self.serviceState == .enabled {
            installRequested = true
        }
    }
    
    func updateServerState(from command: Command, with payload: Codable? = nil) {
        Commands.send(command, payload: payload) { response in
            if let state = response as? ServerState {
                self.serverState = state
                if let p = serverState.port {
                    if self.port == "" {
                        self.port = String(p)
                    }
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
    
    func pairAppleTV() {
        isPairing = true
        Commands.send(.APPLETV_PAIR) { response in
            if let errorCode = response as? ErrorCode {
                print(errorCode)
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
                    Toggle(isOn: $installRequested) {
                        Text("Install as system service")
                    }
                    .toggleStyle(.switch)
                    if serviceState == .requiresApproval {
                        Text("Please allow idevicedebuglauncher in the Background")
                            .foregroundColor(.red)
                    }
                    if serviceState == .enabled {
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
                        pairAppleTV()
                    } label: {
                        Text("Pair Apple TV")
                            .padding(20)
                    }
                }
                
                if isPairing {
                    VStack(alignment: .leading) {
                        Text("Navigate to Settings > Remotes and Devices > Remote App and Devices on your AppleTV and enter the code shown below")
                        OTPView(viewModel: code)
                    }
                        .frame(maxHeight: .infinity)
                } else {
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
        }
        .padding()
        .task {
            getServiceState()
        }
        .onChange(of: code.otpField) { value in
            if value.count == 6 {
                isPairing = false
                code.clear()
            }
        }
        .onReceive(timer) { time in
            if serviceState != .notRegistered {
                getServiceState()
            }
        }
        .onChange(of: installRequested) { newValue in
            DispatchQueue.global(qos: .userInitiated).async {
                if newValue {
                    Commands.register()
                    updateDevices()
                } else {
                    Commands.unregister()
                }
                getServiceState()
                updateServerState(from: .GET_SERVER_STATE)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
