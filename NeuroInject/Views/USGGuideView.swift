import SwiftUI

struct USGGuideView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "waveform.path.ecg.rectangle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Ultrasound Guide Library")
                    .font(.title2.bold())
                
                Text("Detailed probe placement and real-time USG views for all muscles coming soon.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                List {
                    Section("Proximal Upper Extremity") {
                        Text("Biceps Brachii (Short & Long Head)")
                        Text("Brachialis")
                        Text("Triceps")
                    }
                    Section("Distal Upper Extremity") {
                        Text("Flexor Carpi Radialis")
                        Text("Flexor Carpi Ulnaris")
                        Text("Flexor Digitorum Profundus")
                    }
                }
            }
            .navigationTitle("USG Library")
        }
    }
}

struct USGGuideView_Previews: PreviewProvider {
    static var previews: some View {
        USGGuideView()
            .preferredColorScheme(.dark)
    }
}
