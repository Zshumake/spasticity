import SwiftUI

struct BillingCodingView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("CPT Codes - Chemodenervation") {
                    CodeRow(code: "64642", description: "First extremity muscle(s), any muscle(s)")
                    CodeRow(code: "64643", description: "Each additional extremity muscle(s), any muscle(s) (List separately in addition to code for primary procedure)")
                    CodeRow(code: "64644", description: "Cervical spinal muscle(s) (e.g., for torticollis)")
                    CodeRow(code: "64646", description: "Trunk muscle(s) (e.g., for dystonia, spasticity)")
                }
                
                Section("Guidance Codes") {
                    CodeRow(code: "+76942", description: "Ultrasound guidance for needle placement")
                    CodeRow(code: "+95873", description: "Electrical stimulation for guidance")
                    CodeRow(code: "+95874", description: "Needle electromyography for guidance")
                }
                
                Section("Common ICD-10 Codes") {
                    CodeRow(code: "G35", description: "Multiple Sclerosis")
                    CodeRow(code: "G80.0", description: "Spastic quadriplegic cerebral palsy")
                    CodeRow(code: "I69.341", description: "Spastic hemiplegia following cerebral infarction affecting right dominant side")
                }
                
                Section {
                    Text("💡 Tip: Always check payer-specific LCDs (Local Coverage Determinations).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Billing & Coding")
        }
    }
}

struct CodeRow: View {
    let code: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(code)
                .font(.headline)
                .foregroundColor(.blue)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct BillingCodingView_Previews: PreviewProvider {
    static var previews: some View {
        BillingCodingView()
            .preferredColorScheme(.dark)
    }
}
