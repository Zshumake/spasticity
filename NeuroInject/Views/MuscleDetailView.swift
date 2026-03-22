import SwiftUI

struct MuscleDetailView: View {
    let muscle: Muscle
    @State private var showingDosage = false
    @State private var selectedLayer: Muscle.ViewLayer = .muscular
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Layer Switcher
                Picker("Anatomical Layer", selection: $selectedLayer) {
                    ForEach(Muscle.ViewLayer.allCases, id: \.self) { layer in
                        Text(layer.rawValue).tag(layer)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Anatomical Header
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(height: 300)
                        .overlay(
                            Group {
                                if let marker = muscle.marker {
                                    // Simulated Image for now
                                    Image(systemName: "figure.arms.open")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(40)
                                        .opacity(0.3)
                                    
                                    // The Marker
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .position(x: 300 * (marker.x/100), y: 300 * (marker.y/100))
                                        .shadow(radius: 5)
                                        .onTapGesture {
                                            triggerHaptic()
                                            withAnimation {
                                                showingDosage.toggle()
                                            }
                                        }
                                } else {
                                    Text("Image Placeholder")
                                        .foregroundColor(.secondary)
                                }
                            }
                        )
                    
                    if let dosage = muscle.dosage, showingDosage {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Suggested: \(dosage)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        // Depth Indicator for Deep Muscles
                        if selectedLayer == .crossSection {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.down.to.line")
                                        .foregroundColor(.purple)
                                    Text("Injection Depth")
                                        .font(.headline)
                                }
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 12)
                                    Capsule()
                                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 200, height: 12) // Simulated depth
                                }
                                Text("Deep compartment - Target is deep to FDS")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                        }

                        InfoCard(title: "Bony Landmarks", icon: "mappin.and.ellipse", content: muscle.landmarks, color: .blue)
                        InfoCard(title: "Needle Placement", icon: "needle", content: muscle.placement, color: .orange)
                        
                        if let usg = muscle.usgInstructions {
                            InfoCard(title: "Ultrasound Guide", icon: "waveform.path.ecg", content: usg, color: .green)
                        } else {
                            InfoCard(title: "Setup & Guidance", icon: "info.circle", content: muscle.setup, color: .green)
                        }

                        // Resident Tool: Procedure Note Generator
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Resident Tools")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            Button(action: {
                                let note = "Under ultrasound guidance, the needle was advanced into the \(muscle.name) muscle. Position was confirmed with muscular architecture and neurostimulation/EMG. After negative aspiration, Botulinum Toxin was injected."
                                UIPasteboard.general.string = note
                                triggerHaptic()
                            }) {
                                Label("Copy Procedure Note", systemImage: "doc.on.clipboard")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(muscle.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct InfoCard: View {
    let title: String
    let icon: String?
    let content: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let ic = icon {
                    Image(systemName: ic)
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MuscleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MuscleDetailView(muscle: Muscle.mock)
        }
        .preferredColorScheme(.dark)
    }
}
