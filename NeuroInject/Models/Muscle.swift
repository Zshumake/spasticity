import Foundation

struct Muscle: Identifiable, Codable {
    let id: String
    let name: String
    let group: String
    let pattern: String
    let landmarks: String
    let placement: String
    let setup: String
    let usgInstructions: String?
    let dosage: String?
    let marker: Marker?
    
    enum ViewLayer: String, CaseIterable, Codable {
        case surface = "Surface"
        case muscular = "Muscular"
        case crossSection = "Cross-Section"
    }
    
    struct Marker: Codable {
        let body: String
        let x: Double
        let y: Double
    }
}

extension Muscle {
    static let mock = Muscle(
        id: "biceps",
        name: "Biceps Brachii",
        group: "Upper Extremity",
        pattern: "Elbow flexion, Forearm supination",
        landmarks: "Coracoid process, Acromion, Bicipital groove",
        placement: "Mid-humeral level, anterior compartment. Both long and medial heads should be injected.",
        setup: "Surface anatomy is usually sufficient, but USG ensures depth and avoids Brachialis if targeted separately.",
        dosage: "50-100 Units",
        marker: Marker(body: "arm_anterior", x: 45, y: 30)
    )
}
