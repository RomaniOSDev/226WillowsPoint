import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable, Codable, Hashable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"

    var id: String { rawValue }

    var displayName: String { rawValue }
}
