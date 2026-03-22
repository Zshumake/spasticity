import SwiftUI

struct CalibrationView: View {
    @State private var markerPosition = CGPoint(x: 150, y: 150)
    @State private var imageSize = CGSize.zero
    
    // Convert CGPoint to percentages for JSON
    var xPercent: Double {
        guard imageSize.width > 0 else { return 0 }
        return (markerPosition.x / imageSize.width) * 100
    }
    
    var yPercent: Double {
        guard imageSize.height > 0 else { return 0 }
        return (markerPosition.y / imageSize.height) * 100
    }
    
    var body: some View {
        VStack {
            Text("Anatomical Calibration Tool")
                .font(.title2.bold())
                .padding()
            
            Text("Drag the red marker to the exact clinical injection point.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                // Background Illustration
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        // This would be your Netter-style image
                        Image(systemName: "figure.arms.open")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .opacity(0.4)
                    )
                    .background(
                        GeometryReader { proxy in
                            Color.clear.onAppear {
                                imageSize = proxy.size
                            }
                        }
                    )
                
                // The Calibration Marker
                Circle()
                    .fill(Color.red)
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .position(markerPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                markerPosition = value.location
                            }
                    )
                    .shadow(radius: 10)
            }
            .frame(height: 400)
            .padding()
            
            // Output for Developer
            VStack(alignment: .leading, spacing: 10) {
                Text("Clinical Coordinates")
                    .font(.headline)
                
                HStack {
                    CoordinateBox(label: "X (%)", value: String(format: "%.1f", xPercent))
                    CoordinateBox(label: "Y (%)", value: String(format: "%.1f", yPercent))
                }
                
                Button(action: {
                    UIPasteboard.general.string = "\"x\": \(Math.round(xPercent)), \"y\": \(Math.round(yPercent))"
                }) {
                    Label("Copy for JSON", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct CoordinateBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView()
            .preferredColorScheme(.dark)
    }
}
