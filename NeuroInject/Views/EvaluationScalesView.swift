import SwiftUI

struct EvaluationScalesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Modified Ashworth Scale (MAS)") {
                    ScaleRow(score: "0", description: "No increase in muscle tone")
                    ScaleRow(score: "1", description: "Slight increase in muscle tone, manifested by a catch and release or by minimal resistance at the end of the ROM")
                    ScaleRow(score: "1+", description: "Slight increase in muscle tone, manifested by a catch, followed by minimal resistance throughout the remainder (less than half) of the ROM")
                    ScaleRow(score: "2", description: "More marked increase in muscle tone through most of the ROM, but affected part(s) easily moved")
                    ScaleRow(score: "3", description: "Considerable increase in muscle tone, passive movement difficult")
                    ScaleRow(score: "4", description: "Affected part(s) rigid in flexion or extension")
                }
                
                Section("Modified Tardieu Scale (MTS)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quality of Muscle Reaction (X)")
                            .font(.headline)
                        ScaleRow(score: "0", description: "No resistance throughout the course of the passive movement")
                        ScaleRow(score: "1", description: "Slight resistance throughout the course of passive movement, with no clear catch at a precise angle")
                        ScaleRow(score: "2", description: "Clear catch at a precise angle, interrupting the passive movement, followed by release")
                        ScaleRow(score: "3", description: "Fatigable clonus (<10s) occurring at a precise angle")
                        ScaleRow(score: "4", description: "Infatigable clonus (>10s) occurring at a precise angle")
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Evaluation Scales")
        }
    }
}

struct ScaleRow: View {
    let score: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(score)
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct EvaluationScalesView_Previews: PreviewProvider {
    static var previews: some View {
        EvaluationScalesView()
            .preferredColorScheme(.dark)
    }
}
