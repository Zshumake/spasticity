import SwiftUI

struct ContentView: View {
    @StateObject private var store = MuscleStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MuscleListView()
                .environmentObject(store)
                .tabItem {
                    Label("Guide", systemImage: "figure.walk")
                }
                .tag(0)
            
            USGGuideView()
                .tabItem {
                    Label("USG", systemImage: "waveform.path.ecg")
                }
                .tag(1)
            
            ToxinCalculatorView()
                .tabItem {
                    Label("Calc", systemImage: "plus.forwardslash.minus")
                }
                .tag(2)
            
            EvaluationScalesView()
                .tabItem {
                    Label("Scales", systemImage: "list.bullet.clipboard")
                }
                .tag(3)
            
            BillingCodingView()
                .tabItem {
                    Label("Hub", systemImage: "briefcase")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
