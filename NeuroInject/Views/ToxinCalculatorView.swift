import SwiftUI

struct ToxinCalculatorView: View {
    @State private var selectedBrand = "Botox"
    @State private var vialSize = 100.0
    @State private var dilutionVolume = 2.0
    @State private var doseUnits = 50.0
    
    let brands = ["Botox", "Xeomin", "Dysport", "Myobloc"]
    
    var unitsPerMl: Double {
        vialSize / dilutionVolume
    }
    
    var volumeToInject: Double {
        doseUnits / unitsPerMl
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Toxin Details") {
                    Picker("Brand", selection: $selectedBrand) {
                        ForEach(brands, id: \.self) { brand in
                            Text(brand)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        Text("Vial Size (Units)")
                        Spacer()
                        TextField("Units", value: $vialSize, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Dilution (mL Saline)")
                        Spacer()
                        Stepper("\(dilutionVolume, specifier: "%.1f") mL", value: $dilutionVolume, in: 0.5...10.0, step: 0.5)
                    }
                }
                
                Section("Target Dose") {
                    HStack {
                        Text("Desired Dose (Units)")
                        Spacer()
                        TextField("Units", value: $doseUnits, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Result") {
                    CalculationRow(label: "Concentration", value: "\(unitsPerMl, specifier: "%.0f") U / mL", color: .blue)
                    CalculationRow(label: "Injection Volume", value: "\(volumeToInject, specifier: "%.2f") mL", color: .green)
                    
                    if selectedBrand == "Dysport" {
                        Text("⚠️ Dysport units are not 1:1 with Botox/Xeomin.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Toxin Calculator")
        }
    }
}

struct CalculationRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

struct ToxinCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ToxinCalculatorView()
            .preferredColorScheme(.dark)
    }
}
