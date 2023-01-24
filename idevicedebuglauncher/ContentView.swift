import SwiftUI

struct ContentView: View {
    @State private var installed = false
    @State private var running = false
    
    @State private var devices = [
        DeviceInfo(deviceId: "00008110-001E059026C1801E", deviceType: .usb),
        DeviceInfo(deviceId: "00008110-001E059026C1801E", deviceType: .network),
        DeviceInfo(deviceId: "bbc1630faa46f5acb41938898ef7b26e912f9bf8", deviceType: .network),

        ]
    
    var body: some View {
        
        HStack {
            Image("logo")
                .padding(.trailing, 20)
            VStack(alignment: .leading) {
                
                Toggle(isOn: $installed) {
                    Text("Install as system service")
                }
                
                HStack {
                    Text("Status: ")
                    Label(running ? "on" : "off", systemImage: "circle.fill")
                        .foregroundColor(running ? .green : .red)
                }
                
                Divider()
                
                HStack {
                    Button {
                        Commands.send("listDevices")
                    } label: {
                        Text("List devices")
                            .padding(20)
                    }
                    Button {
                        Commands.send("pair")
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
            if newValue {
                Commands.register()
            } else {
                Commands.unregister()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
