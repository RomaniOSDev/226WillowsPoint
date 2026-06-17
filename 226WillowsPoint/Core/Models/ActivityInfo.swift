import Foundation

struct ActivityInfo: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String

    static let all: [ActivityInfo] = [
        ActivityInfo(
            id: "rune_trail",
            title: "Rune Trail",
            subtitle: "Tap hidden runes before they fade away",
            iconName: "sparkles"
        ),
        ActivityInfo(
            id: "rune_river_run",
            title: "Rune River Run",
            subtitle: "Guide the orb along mystical pathways",
            iconName: "point.topleft.down.to.point.bottomright.curvepath"
        ),
        ActivityInfo(
            id: "rune_rhythm_quest",
            title: "Rune Rhythm Quest",
            subtitle: "Charge runes with precise long-press timing",
            iconName: "waveform.path"
        )
    ]

    static func find(by id: String) -> ActivityInfo? {
        all.first { $0.id == id }
    }

    var imageAssetName: String {
        switch id {
        case "rune_trail": return "ActivityTrail"
        case "rune_river_run": return "ActivityRiver"
        case "rune_rhythm_quest": return "ActivityRhythm"
        default: return "ActivityTrail"
        }
    }
}
