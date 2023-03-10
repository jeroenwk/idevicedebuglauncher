import SwiftUI
import ServiceManagement

struct ContentView: View {
    @State private var serviceState = SMAppService.Status(rawValue: 0)
    @State private var serverState = ServerState(running: false)
    
    // ui
    @State private var installRequested = false
    @State private var devices: [DeviceInfo] = []
    @State private var port = ""
    @State private var bundleId = ""
    @State private var isPairing = false
    @State private var pairingStatus: String?
    @ObservedObject private var code = OTPModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func attachDebugger(udid: String) {
        if bundleId != "" { //TODO: be more restrictive
            let payload = DebugRequest(udid: udid, bundleId: bundleId)
            Commands.send(.ATTACH_DEBUGGER, payload: payload) { response in
                if let error = (response as? ErrorCode)?.error {
                    logger.error("\(error)")
                }
            }
        }
    }
    
    func getServiceState() {
        self.serviceState = Commands.status()
        updateServiceState()
    }
    
    func pairAppleTV() {
        isPairing = true
        Commands.send(.APPLETV_PAIR) { response in
            if let errorCode = response as? ErrorCode {
                if errorCode.code > 0 {
                    pairingStatus = "AppleTV not paired!"
                } else {
                    pairingStatus = "AppleTV paired"
                }
                isPairing = false
            }
        }
    }
    
    func setPinCode(_ code: String) {
        Commands.send(.SET_PIN, payload: code) { response in
            if let error = (response as? ErrorCode)?.error {
                logger.error("\(error)")
            }
        }
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
            updateServerState(from: .GET_SERVER_STATE)
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
                
                if let pairingStatus {
                    Text(pairingStatus)
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

                
                HStack {
                    Text("Bundle Identifier to debug:")
                    TextField("com.developer.app", text: $bundleId)
                }
                
                if isPairing {
                    VStack(alignment: .center) {
                        Image(systemName: "appletv.fill")
                            .font(.system(size: 50))
                        
                        OTPView(viewModel: code)
                            .padding()
                        Text("Navigate to Settings > Remotes and Devices > Remote App and Devices on your AppleTV and enter the code shown below")
                        Button {
                            isPairing = false
                        } label: {
                            Text("Undo pairing")
                                .padding(20)
                        }
                    }
                        .frame(maxHeight: .infinity)
                } else {
                    Text("Devices")
                        .font(.headline)
                    
                    Table(devices) {
                        TableColumn("Id", value: \.deviceId)
                        TableColumn("Model") { device in
                            if let info = device.extraInfo,
                               let model = info["DeviceClass"] {
                                Label(model, systemImage: model.lowercased())
                            }
                        }
                        TableColumn("Connection") { device in
                            if let deviceType = device.deviceType {
                                Label(deviceType.description, systemImage: deviceType.icon)
                            }
                        }
                        TableColumn("Debug") { device in
                            Button {
                                attachDebugger(udid: device.deviceId)
                            } label: {
                                Image(systemName: "play.circle")
                                .foregroundColor(.accentColor)
                        }
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
                setPinCode(value)
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
