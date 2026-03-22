import Foundation
import Combine

class MuscleStore: ObservableObject {
    @Published var muscles: [Muscle] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // In a real app, this would check the Documents folder for calibrated data first,
        // then fall back to the main bundle.
        if let url = Bundle.main.url(forResource: "muscles", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.muscles = try decoder.decode([Muscle].self, from: data)
            } catch {
                print("Error loading muscles: \(error)")
                self.muscles = [Muscle.mock] // Fallback
            }
        } else {
            self.muscles = [Muscle.mock]
        }
    }
}
