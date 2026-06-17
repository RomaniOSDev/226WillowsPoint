import Foundation

enum RuneRarity: String, CaseIterable, Codable {
    case common = "Common"
    case rare = "Rare"
    case ancient = "Ancient"
}

enum RuneSymbol: Int, CaseIterable, Codable {
    case spiral
    case cross
    case triangle
    case diamond
    case wave
    case sun
    case moon
    case leaf
    case flame
    case star
    case circle
    case arrow
    case hexagon
    case bolt
    case eye
    case seal
    case gate
    case crown
}

struct RuneDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let lore: String
    let rarity: RuneRarity
    let symbol: RuneSymbol
    let unlockKey: String

    static let catalog: [RuneDefinition] = [
        RuneDefinition(id: "rune_ember", name: "Ember Rune", lore: "A faint warmth lingers where ancient fires once burned beneath the grove.", rarity: .common, symbol: .flame, unlockKey: "rune_trail_Easy_0"),
        RuneDefinition(id: "rune_leaf", name: "Leaf Rune", lore: "Whispered by wind through enchanted branches, it marks the first step outward.", rarity: .common, symbol: .leaf, unlockKey: "rune_trail_Easy_1"),
        RuneDefinition(id: "rune_spiral", name: "Spiral Rune", lore: "Curves inward and outward, teaching patience to those who trace its path.", rarity: .common, symbol: .spiral, unlockKey: "rune_trail_Easy_2"),
        RuneDefinition(id: "rune_wave", name: "Wave Rune", lore: "Flows like a hidden stream beneath the stones, guiding travelers onward.", rarity: .common, symbol: .wave, unlockKey: "rune_trail_Normal_0"),
        RuneDefinition(id: "rune_sun", name: "Sun Rune", lore: "Casts golden light across the circle, revealing pathways long forgotten.", rarity: .rare, symbol: .sun, unlockKey: "rune_trail_Normal_2"),
        RuneDefinition(id: "rune_moon", name: "Moon Rune", lore: "Glows softly at dusk, unlocking trails visible only under starlight.", rarity: .rare, symbol: .moon, unlockKey: "rune_trail_Hard_1"),
        RuneDefinition(id: "rune_diamond", name: "Diamond Rune", lore: "Sharp and brilliant, it cuts through illusions woven by the forest.", rarity: .common, symbol: .diamond, unlockKey: "rune_river_run_Easy_0"),
        RuneDefinition(id: "rune_arrow", name: "Arrow Rune", lore: "Points the way through winding channels where the orb must not stray.", rarity: .common, symbol: .arrow, unlockKey: "rune_river_run_Easy_2"),
        RuneDefinition(id: "rune_circle", name: "Circle Rune", lore: "Endless and unbroken, it guards the checkpoints along the river path.", rarity: .common, symbol: .circle, unlockKey: "rune_river_run_Normal_1"),
        RuneDefinition(id: "rune_hexagon", name: "Hex Rune", lore: "Six-sided and steady, anchoring the orb against shifting currents.", rarity: .rare, symbol: .hexagon, unlockKey: "rune_river_run_Normal_3"),
        RuneDefinition(id: "rune_bolt", name: "Bolt Rune", lore: "Crackles with energy, demanding swift and precise navigation.", rarity: .rare, symbol: .bolt, unlockKey: "rune_river_run_Hard_2"),
        RuneDefinition(id: "rune_cross", name: "Cross Rune", lore: "Four arms reach outward, marking the rhythm of the first charge.", rarity: .common, symbol: .cross, unlockKey: "rune_rhythm_quest_Easy_0"),
        RuneDefinition(id: "rune_triangle", name: "Triangle Rune", lore: "Three points of power align when held with perfect timing.", rarity: .common, symbol: .triangle, unlockKey: "rune_rhythm_quest_Easy_2"),
        RuneDefinition(id: "rune_star", name: "Star Rune", lore: "Pulses in sequence, rewarding those who master the charge.", rarity: .rare, symbol: .star, unlockKey: "rune_rhythm_quest_Normal_2"),
        RuneDefinition(id: "rune_eye", name: "Eye Rune", lore: "Watches over the sequence, unblinking until all runes are charged.", rarity: .rare, symbol: .eye, unlockKey: "rune_rhythm_quest_Hard_1"),
        RuneDefinition(id: "rune_gate", name: "Gate Rune", lore: "Opens only when every trial in a chapter has been conquered.", rarity: .ancient, symbol: .gate, unlockKey: "path_chapter_1"),
        RuneDefinition(id: "rune_crown", name: "Crown Rune", lore: "Reserved for explorers who weave every path through the enchanted forest.", rarity: .ancient, symbol: .crown, unlockKey: "path_chapter_3"),
        RuneDefinition(id: "rune_seal", name: "Daily Seal", lore: "Awarded to those who answer the forest's call each day without fail.", rarity: .ancient, symbol: .seal, unlockKey: "daily_challenge")
    ]

    static func forUnlockKey(_ key: String) -> RuneDefinition? {
        catalog.first { $0.unlockKey == key }
    }

    static func forLevel(activityId: String, difficulty: GameDifficulty, level: Int) -> RuneDefinition? {
        forUnlockKey("\(activityId)_\(difficulty.rawValue)_\(level)")
    }
}
