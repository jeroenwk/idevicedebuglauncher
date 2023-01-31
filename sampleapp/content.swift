import SwiftUI
import idevicedebuglauncherlibswift

struct ContentView: View {
    @State private var isDebugged = false
    
    @ObservedObject var lib = idevicedebuglauncherlib()
    
    struct ErrorCode: Codable {
        var code: Int
        var error: String?
    }
    
    var body: some View {
        VStack {
            Image("sample_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80.0)
            
            Group {
                if isDebugged {
                    Text("I'm being debugged")
                } else {
                    Text("Waiting to be debugged")
                }
            }
            .font(.title)
            .foregroundColor(Color(red: 0.778, green: 0.159, blue: 0.155))
            
            Text(lib.info)
        }
        .padding()
        .task {
            if await lib.findAndConnect() {
                isDebugged = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
