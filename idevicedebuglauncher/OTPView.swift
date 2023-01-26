import SwiftUI

class OTPModel: ObservableObject {
    @Published var isTextFieldDisabled = false
    
    @Published var otpField = "" {
        didSet {
            guard otpField.count <= 6,
                  otpField.last?.isNumber ?? true else {
                otpField = oldValue
                return
            }
        }
    }
    
    public func clear() {
        otpField = ""
    }
    
    var otp1: String {
        guard otpField.count >= 1 else {
            return ""
        }
        return String(Array(otpField)[0])
    }
    var otp2: String {
        guard otpField.count >= 2 else {
            return ""
        }
        return String(Array(otpField)[1])
    }
    var otp3: String {
        guard otpField.count >= 3 else {
            return ""
        }
        return String(Array(otpField)[2])
    }
    var otp4: String {
        guard otpField.count >= 4 else {
            return ""
        }
        return String(Array(otpField)[3])
    }
    
    var otp5: String {
        guard otpField.count >= 5 else {
            return ""
        }
        return String(Array(otpField)[4])
    }
    
    var otp6: String {
        guard otpField.count >= 6 else {
            return ""
        }
        return String(Array(otpField)[5])
    }
}

struct OTPView: View {
    @StateObject var viewModel = OTPModel()
    @State var isFocused = true
    
    let textBoxWidth = 50.0
    let textBoxHeight = 50.0
    let spaceBetweenBoxes: CGFloat = 10
    let paddingOfBox: CGFloat = 1
    @FocusState var focused: Bool?
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                TextField("", text: $viewModel.otpField)
                    .frame(width: 0, height: 0)
                    .disabled(viewModel.isTextFieldDisabled)
                    .textContentType(.oneTimeCode)
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .background(Color.clear)
                    .focused($focused, equals: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            self.focused = true
                        }
                    }
                
                HStack (spacing: spaceBetweenBoxes){
                    otpText(text: viewModel.otp1)
                    otpText(text: viewModel.otp2)
                    otpText(text: viewModel.otp3)
                    otpText(text: viewModel.otp4)
                    otpText(text: viewModel.otp5)
                    otpText(text: viewModel.otp6)
                }
                
                
                
            }
        }
    }
    
    private func otpText(text: String) -> some View {
        
        return Text(text)
            .font(.largeTitle)
            .foregroundColor(Color.primary)
            .frame(width: 50.0, height: 50.0)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color.primary)
                    .opacity(0.1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(paddingOfBox)
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView()
    }
}
