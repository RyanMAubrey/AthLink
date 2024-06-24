import SwiftUI

struct ContentView: View, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(1)
    }
    
    static func ==(lhs: ContentView, rhs: ContentView) -> Bool {
            return true
    }

    var body: some View {
        Text("AthLink")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()

        
    }
}

#Preview {
    ContentView()
}
