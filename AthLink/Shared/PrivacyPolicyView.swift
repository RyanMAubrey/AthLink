import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        VStack {
            Text("Privacy Policy")
                .font(.largeTitle)
                .padding()

            Text("this is the Privacy Policy")
                .padding()
            
            Spacer()
        }
    }
}


#Preview {
    PrivacyPolicyView()
}
