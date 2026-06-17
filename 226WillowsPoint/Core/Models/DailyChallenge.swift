import Foundation

struct DailyChallenge: Identifiable, Hashable {
    let id: String
    let dateKey: String
    let route: LevelRoute
    let title: String
    let flavorText: String

    static func forDate(_ date: Date = Date()) -> DailyChallenge {
        let key = dateKey(from: date)
        let seed = stableSeed(from: key)

        let activities = ActivityInfo.all
        let difficulties = GameDifficulty.allCases

        let activityIndex = seed % activities.count
        let difficultyIndex = (seed / activities.count) % difficulties.count
        let levelIndex = (seed / (activities.count * difficulties.count)) % 5

        let activity = activities[activityIndex]
        let difficulty = difficulties[difficultyIndex]

        let titles = [
            "Mystic Trial of the Day",
            "Forest's Daily Riddle",
            "Ancient Path Challenge",
            "Rune Keeper's Test",
            "Starlit Daily Quest"
        ]

        return DailyChallenge(
            id: "daily_\(key)",
            dateKey: key,
            route: LevelRoute(activityId: activity.id, difficulty: difficulty, level: levelIndex, isDailyChallenge: true),
            title: titles[seed % titles.count],
            flavorText: "Today's seal awaits in \(activity.title) — \(difficulty.displayName), Level \(levelIndex + 1)."
        )
    }

    static func forToday() -> DailyChallenge {
        forDate(Date())
    }

    private static func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private static func stableSeed(from key: String) -> Int {
        abs(key.hashValue)
    }
}
