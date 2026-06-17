import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: Bool

    static func all(from storage: AppStorage) -> [Achievement] {
        [
            Achievement(
                id: "first_star",
                title: "First Star",
                description: "You've earned your first STAR.",
                iconName: "star.fill",
                isUnlocked: storage.totalStarsEarned >= 1
            ),
            Achievement(
                id: "adventurer",
                title: "Adventurer",
                description: "Played 10 activities in total.",
                iconName: "figure.walk",
                isUnlocked: storage.totalActivitiesPlayed >= 10
            ),
            Achievement(
                id: "time_explorer",
                title: "Time Explorer",
                description: "'s over an hour of playtime.",
                iconName: "clock.fill",
                isUnlocked: storage.totalPlayTimeSeconds >= 3600
            ),
            Achievement(
                id: "puzzle_master",
                title: "Puzzle Master",
                description: "Achieved at least 5 stars per activity.",
                iconName: "puzzlepiece.fill",
                isUnlocked: storage.hasFiveStarsPerActivity
            ),
            Achievement(
                id: "level_unlocker",
                title: "Level Unlocker",
                description: "Unlocked 3 new levels on your adventure.",
                iconName: "lock.open.fill",
                isUnlocked: storage.totalNewLevelsUnlocked >= 3
            ),
            Achievement(
                id: "star_collector",
                title: "Star Collector",
                description: "Collected a total of 50 STARS.",
                iconName: "star.circle.fill",
                isUnlocked: storage.totalStarsEarned >= 50
            ),
            Achievement(
                id: "streak_seeker",
                title: "Streak Seeker",
                description: "Maintained a play streak for a week.",
                iconName: "flame.fill",
                isUnlocked: storage.streakCount >= 7
            ),
            Achievement(
                id: "onboarded_explorer",
                title: "Onboarded Explorer",
                description: "Completed the onboarding process.",
                iconName: "map.fill",
                isUnlocked: storage.hasSeenOnboarding
            ),
            Achievement(
                id: "codex_scholar",
                title: "Codex Scholar",
                description: "Discovered 10 runes in the Codex.",
                iconName: "book.fill",
                isUnlocked: storage.discoveredRuneCount >= 10
            ),
            Achievement(
                id: "daily_guardian",
                title: "Daily Guardian",
                description: "Maintained a daily challenge streak for a week.",
                iconName: "seal.fill",
                isUnlocked: storage.dailyChallengeStreak >= 7
            ),
            Achievement(
                id: "path_weaver",
                title: "Path Weaver",
                description: "Cleared 5 nodes on the forest path map.",
                iconName: "point.topleft.down.to.point.bottomright.curvepath",
                isUnlocked: storage.completedPathNodeCount >= 5
            )
        ]
    }
}
