import Foundation
import CoreGraphics

enum PathChapter: String, CaseIterable, Identifiable {
    case whisperingGrove = "Whispering Grove"
    case stoneCircle = "Stone Circle"
    case moonlitCrossing = "Moonlit Crossing"

    var id: String { rawValue }

    var intro: String {
        switch self {
        case .whisperingGrove:
            return "Ancient trees hum with hidden runes. Begin your trail here."
        case .stoneCircle:
            return "A ring of stones marks the river's source. Navigate with care."
        case .moonlitCrossing:
            return "Under pale moonlight, rhythm and timing unlock the final path."
        }
    }
}

struct PathMapNode: Identifiable, Hashable {
    let id: String
    let chapter: PathChapter
    let title: String
    let normalizedPosition: CGPoint
    let route: LevelRoute
    let prerequisiteId: String?

    static let allNodes: [PathMapNode] = [
        PathMapNode(id: "path_01", chapter: .whisperingGrove, title: "Grove Entry", normalizedPosition: CGPoint(x: 0.15, y: 0.82), route: LevelRoute(activityId: "rune_trail", difficulty: .easy, level: 0), prerequisiteId: nil),
        PathMapNode(id: "path_02", chapter: .whisperingGrove, title: "Hidden Trail", normalizedPosition: CGPoint(x: 0.32, y: 0.68), route: LevelRoute(activityId: "rune_trail", difficulty: .easy, level: 1), prerequisiteId: "path_01"),
        PathMapNode(id: "path_03", chapter: .whisperingGrove, title: "Canopy Light", normalizedPosition: CGPoint(x: 0.50, y: 0.75), route: LevelRoute(activityId: "rune_trail", difficulty: .normal, level: 0), prerequisiteId: "path_02"),
        PathMapNode(id: "path_04", chapter: .whisperingGrove, title: "Root Bridge", normalizedPosition: CGPoint(x: 0.68, y: 0.62), route: LevelRoute(activityId: "rune_trail", difficulty: .normal, level: 2), prerequisiteId: "path_03"),
        PathMapNode(id: "path_05", chapter: .stoneCircle, title: "Circle Gate", normalizedPosition: CGPoint(x: 0.85, y: 0.48), route: LevelRoute(activityId: "rune_river_run", difficulty: .easy, level: 0), prerequisiteId: "path_04"),
        PathMapNode(id: "path_06", chapter: .stoneCircle, title: "River Bend", normalizedPosition: CGPoint(x: 0.72, y: 0.35), route: LevelRoute(activityId: "rune_river_run", difficulty: .easy, level: 2), prerequisiteId: "path_05"),
        PathMapNode(id: "path_07", chapter: .stoneCircle, title: "Boulder Pass", normalizedPosition: CGPoint(x: 0.55, y: 0.42), route: LevelRoute(activityId: "rune_river_run", difficulty: .normal, level: 1), prerequisiteId: "path_06"),
        PathMapNode(id: "path_08", chapter: .stoneCircle, title: "Deep Channel", normalizedPosition: CGPoint(x: 0.38, y: 0.30), route: LevelRoute(activityId: "rune_river_run", difficulty: .hard, level: 0), prerequisiteId: "path_07"),
        PathMapNode(id: "path_09", chapter: .moonlitCrossing, title: "Moon Arch", normalizedPosition: CGPoint(x: 0.22, y: 0.38), route: LevelRoute(activityId: "rune_rhythm_quest", difficulty: .easy, level: 0), prerequisiteId: "path_08"),
        PathMapNode(id: "path_10", chapter: .moonlitCrossing, title: "Pulse Clearing", normalizedPosition: CGPoint(x: 0.18, y: 0.22), route: LevelRoute(activityId: "rune_rhythm_quest", difficulty: .easy, level: 2), prerequisiteId: "path_09"),
        PathMapNode(id: "path_11", chapter: .moonlitCrossing, title: "Rhythm Gate", normalizedPosition: CGPoint(x: 0.40, y: 0.15), route: LevelRoute(activityId: "rune_rhythm_quest", difficulty: .normal, level: 2), prerequisiteId: "path_10"),
        PathMapNode(id: "path_12", chapter: .moonlitCrossing, title: "Star Crossing", normalizedPosition: CGPoint(x: 0.62, y: 0.18), route: LevelRoute(activityId: "rune_rhythm_quest", difficulty: .hard, level: 1), prerequisiteId: "path_11"),
        PathMapNode(id: "path_13", chapter: .moonlitCrossing, title: "Final Span", normalizedPosition: CGPoint(x: 0.82, y: 0.12), route: LevelRoute(activityId: "rune_trail", difficulty: .hard, level: 4), prerequisiteId: "path_12")
    ]

    static func node(withId id: String) -> PathMapNode? {
        allNodes.first { $0.id == id }
    }
}
