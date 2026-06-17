import Foundation
import Combine

final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let totalStarsEarned = "totalStarsEarned"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let starsPerActivity = "starsPerActivity"
        static let unlockedLevels = "unlockedLevels"
        static let streakCount = "streakCount"
        static let lastPlayDate = "lastPlayDate"
        static let previouslyUnlockedAchievements = "previouslyUnlockedAchievements"
        static let discoveredRunes = "discoveredRunes"
        static let completedPathNodes = "completedPathNodes"
        static let completedDailyDates = "completedDailyDates"
        static let dailyChallengeStreak = "dailyChallengeStreak"
        static let lastDailyChallengeDate = "lastDailyChallengeDate"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalActivitiesPlayed: Int {
        didSet { UserDefaults.standard.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published var totalStarsEarned: Int {
        didSet { UserDefaults.standard.set(totalStarsEarned, forKey: Keys.totalStarsEarned) }
    }

    @Published var totalPlayTimeSeconds: Int {
        didSet { UserDefaults.standard.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds) }
    }

    @Published var starsPerActivity: [String: [String: [Int]]] {
        didSet { saveDictionary(starsPerActivity, forKey: Keys.starsPerActivity) }
    }

    @Published var unlockedLevels: [String: [String: Int]] {
        didSet { saveDictionary(unlockedLevels, forKey: Keys.unlockedLevels) }
    }

    @Published var streakCount: Int {
        didSet { UserDefaults.standard.set(streakCount, forKey: Keys.streakCount) }
    }

    @Published var discoveredRunes: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(discoveredRunes), forKey: Keys.discoveredRunes)
        }
    }

    @Published var completedPathNodes: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(completedPathNodes), forKey: Keys.completedPathNodes)
        }
    }

    @Published var completedDailyDates: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(completedDailyDates), forKey: Keys.completedDailyDates)
        }
    }

    @Published var dailyChallengeStreak: Int {
        didSet { UserDefaults.standard.set(dailyChallengeStreak, forKey: Keys.dailyChallengeStreak) }
    }

    private var lastPlayDate: String {
        didSet { UserDefaults.standard.set(lastPlayDate, forKey: Keys.lastPlayDate) }
    }

    private var lastDailyChallengeDate: String {
        didSet { UserDefaults.standard.set(lastDailyChallengeDate, forKey: Keys.lastDailyChallengeDate) }
    }

    @Published var previouslyUnlockedAchievements: Set<String> {
        didSet {
            let array = Array(previouslyUnlockedAchievements)
            UserDefaults.standard.set(array, forKey: Keys.previouslyUnlockedAchievements)
        }
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        let defaults = UserDefaults.standard
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        starsPerActivity = Self.loadDictionary(forKey: Keys.starsPerActivity) ?? [:]
        unlockedLevels = Self.loadDictionary(forKey: Keys.unlockedLevels) ?? Self.defaultUnlockedLevels()
        streakCount = defaults.integer(forKey: Keys.streakCount)
        lastPlayDate = defaults.string(forKey: Keys.lastPlayDate) ?? ""
        lastDailyChallengeDate = defaults.string(forKey: Keys.lastDailyChallengeDate) ?? ""
        discoveredRunes = Set(defaults.stringArray(forKey: Keys.discoveredRunes) ?? [])
        completedPathNodes = Set(defaults.stringArray(forKey: Keys.completedPathNodes) ?? [])
        completedDailyDates = Set(defaults.stringArray(forKey: Keys.completedDailyDates) ?? [])
        dailyChallengeStreak = defaults.integer(forKey: Keys.dailyChallengeStreak)
        let savedAchievements = defaults.stringArray(forKey: Keys.previouslyUnlockedAchievements) ?? []
        previouslyUnlockedAchievements = Set(savedAchievements)

        NotificationCenter.default.publisher(for: .progressReset)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    var formattedPlayTime: String {
        let hours = totalPlayTimeSeconds / 3600
        let minutes = (totalPlayTimeSeconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var totalNewLevelsUnlocked: Int {
        var count = 0
        for activity in ActivityInfo.all {
            for difficulty in GameDifficulty.allCases {
                let highest = highestUnlockedLevel(activityId: activity.id, difficulty: difficulty)
                count += max(0, highest)
            }
        }
        return count
    }

    var hasFiveStarsPerActivity: Bool {
        ActivityInfo.all.allSatisfy { activity in
            starsForActivity(activityId: activity.id) >= 5
        }
    }

    var isTodayDailyChallengeCompleted: Bool {
        completedDailyDates.contains(todayDateKey)
    }

    var todayDailyChallenge: DailyChallenge {
        DailyChallenge.forToday()
    }

    var discoveredRuneCount: Int { discoveredRunes.count }

    var completedPathNodeCount: Int { completedPathNodes.count }

    func isRuneDiscovered(_ runeId: String) -> Bool {
        discoveredRunes.contains(runeId)
    }

    func isPathNodeUnlocked(_ nodeId: String) -> Bool {
        guard let node = PathMapNode.node(withId: nodeId) else { return false }
        if node.prerequisiteId == nil { return true }
        if completedPathNodes.contains(nodeId) { return true }
        guard let prerequisite = node.prerequisiteId else { return true }
        return completedPathNodes.contains(prerequisite)
    }

    func isPathNodeCompleted(_ nodeId: String) -> Bool {
        completedPathNodes.contains(nodeId)
    }

    func starsForActivity(activityId: String) -> Int {
        guard let difficulties = starsPerActivity[activityId] else { return 0 }
        return difficulties.values.flatMap { $0 }.reduce(0, +)
    }

    func completedLevelsCount(activityId: String) -> Int {
        var count = 0
        for difficulty in GameDifficulty.allCases {
            for level in 0..<5 {
                if stars(for: activityId, difficulty: difficulty, level: level) >= 1 {
                    count += 1
                }
            }
        }
        return count
    }

    func starsForDifficulty(activityId: String, difficulty: GameDifficulty) -> Int {
        guard let levels = starsPerActivity[activityId]?[difficulty.rawValue] else { return 0 }
        return levels.reduce(0, +)
    }

    func chapterProgress(_ chapter: PathChapter) -> Double {
        let nodes = PathMapNode.allNodes.filter { $0.chapter == chapter }
        guard !nodes.isEmpty else { return 0 }
        let completed = nodes.filter { completedPathNodes.contains($0.id) }.count
        return Double(completed) / Double(nodes.count)
    }

    func stars(for activityId: String, difficulty: GameDifficulty, level: Int) -> Int {
        starsPerActivity[activityId]?[difficulty.rawValue]?[safe: level] ?? 0
    }

    func isLevelUnlocked(activityId: String, difficulty: GameDifficulty, level: Int) -> Bool {
        level <= highestUnlockedLevel(activityId: activityId, difficulty: difficulty)
    }

    func highestUnlockedLevel(activityId: String, difficulty: GameDifficulty) -> Int {
        unlockedLevels[activityId]?[difficulty.rawValue] ?? 0
    }

    func discoverRune(unlockKey: String) {
        guard let rune = RuneDefinition.forUnlockKey(unlockKey) else { return }
        discoveredRunes.insert(rune.id)
    }

    func recordLevelCompletion(
        activityId: String,
        difficulty: GameDifficulty,
        level: Int,
        stars earned: Int,
        playTimeSeconds: Int,
        isDailyChallenge: Bool = false
    ) -> String? {
        let previousAchievements = Set(Achievement.all(from: self).filter(\.isUnlocked).map(\.id))

        let oldStars = stars(for: activityId, difficulty: difficulty, level: level)
        if earned > oldStars {
            var activityStars = starsPerActivity[activityId] ?? [:]
            var difficultyStars = activityStars[difficulty.rawValue] ?? Array(repeating: 0, count: 5)
            while difficultyStars.count <= level {
                difficultyStars.append(0)
            }
            difficultyStars[level] = earned
            activityStars[difficulty.rawValue] = difficultyStars
            starsPerActivity[activityId] = activityStars
            totalStarsEarned += (earned - oldStars)
        }

        if earned >= 1 {
            let nextLevel = level + 1
            if nextLevel < 5 {
                var activityUnlocked = unlockedLevels[activityId] ?? [:]
                let current = activityUnlocked[difficulty.rawValue] ?? 0
                if nextLevel > current {
                    activityUnlocked[difficulty.rawValue] = nextLevel
                    unlockedLevels[activityId] = activityUnlocked
                }
            }

            discoverRune(unlockKey: "\(activityId)_\(difficulty.rawValue)_\(level)")
            completeMatchingPathNodes(activityId: activityId, difficulty: difficulty, level: level)
            checkChapterRunes()
        }

        if isDailyChallenge && earned >= 1 {
            recordDailyChallengeCompletion()
        }

        totalActivitiesPlayed += 1
        totalPlayTimeSeconds += playTimeSeconds
        updateStreak()

        let currentAchievements = Set(Achievement.all(from: self).filter(\.isUnlocked).map(\.id))
        let newlyUnlocked = currentAchievements.subtracting(previousAchievements)
        if let first = newlyUnlocked.sorted().first {
            previouslyUnlockedAchievements.insert(first)
            return first
        }
        return nil
    }

    func resetAllProgress() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.totalStarsEarned)
        defaults.removeObject(forKey: Keys.totalPlayTimeSeconds)
        defaults.removeObject(forKey: Keys.starsPerActivity)
        defaults.removeObject(forKey: Keys.unlockedLevels)
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.lastPlayDate)
        defaults.removeObject(forKey: Keys.previouslyUnlockedAchievements)
        defaults.removeObject(forKey: Keys.discoveredRunes)
        defaults.removeObject(forKey: Keys.completedPathNodes)
        defaults.removeObject(forKey: Keys.completedDailyDates)
        defaults.removeObject(forKey: Keys.dailyChallengeStreak)
        defaults.removeObject(forKey: Keys.lastDailyChallengeDate)
        defaults.synchronize()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    private func completeMatchingPathNodes(activityId: String, difficulty: GameDifficulty, level: Int) {
        for node in PathMapNode.allNodes where
            node.route.activityId == activityId &&
            node.route.difficulty == difficulty &&
            node.route.level == level {
            completedPathNodes.insert(node.id)
        }
    }

    private func checkChapterRunes() {
        let groveDone = PathMapNode.allNodes
            .filter { $0.chapter == .whisperingGrove }
            .allSatisfy { completedPathNodes.contains($0.id) }
        if groveDone { discoverRune(unlockKey: "path_chapter_1") }

        let crossingDone = PathMapNode.allNodes
            .filter { $0.chapter == .moonlitCrossing }
            .allSatisfy { completedPathNodes.contains($0.id) }
        if crossingDone { discoverRune(unlockKey: "path_chapter_3") }
    }

    private func recordDailyChallengeCompletion() {
        let today = todayDateKey
        guard !completedDailyDates.contains(today) else { return }

        completedDailyDates.insert(today)
        discoverRune(unlockKey: "daily_challenge")

        if lastDailyChallengeDate.isEmpty {
            dailyChallengeStreak = 1
        } else if let lastDate = Self.date(from: lastDailyChallengeDate),
                  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                  Self.dateString(from: lastDate) == Self.dateString(from: yesterday) {
            dailyChallengeStreak += 1
        } else if lastDailyChallengeDate == today {
            return
        } else {
            dailyChallengeStreak = 1
        }
        lastDailyChallengeDate = today
    }

    private var todayDateKey: String {
        Self.dateString(from: Date())
    }

    private func reloadFromDefaults() {
        let defaults = UserDefaults.standard
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        starsPerActivity = Self.loadDictionary(forKey: Keys.starsPerActivity) ?? [:]
        unlockedLevels = Self.loadDictionary(forKey: Keys.unlockedLevels) ?? Self.defaultUnlockedLevels()
        streakCount = defaults.integer(forKey: Keys.streakCount)
        lastPlayDate = defaults.string(forKey: Keys.lastPlayDate) ?? ""
        lastDailyChallengeDate = defaults.string(forKey: Keys.lastDailyChallengeDate) ?? ""
        discoveredRunes = Set(defaults.stringArray(forKey: Keys.discoveredRunes) ?? [])
        completedPathNodes = Set(defaults.stringArray(forKey: Keys.completedPathNodes) ?? [])
        completedDailyDates = Set(defaults.stringArray(forKey: Keys.completedDailyDates) ?? [])
        dailyChallengeStreak = defaults.integer(forKey: Keys.dailyChallengeStreak)
        let savedAchievements = defaults.stringArray(forKey: Keys.previouslyUnlockedAchievements) ?? []
        previouslyUnlockedAchievements = Set(savedAchievements)
    }

    private func updateStreak() {
        let today = Self.dateString(from: Date())
        if lastPlayDate == today {
            return
        }
        if let lastDate = Self.date(from: lastPlayDate),
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
           Self.dateString(from: lastDate) == Self.dateString(from: yesterday) {
            streakCount += 1
        } else if lastPlayDate.isEmpty {
            streakCount = 1
        } else {
            streakCount = 1
        }
        lastPlayDate = today
    }

    private static func defaultUnlockedLevels() -> [String: [String: Int]] {
        var result: [String: [String: Int]] = [:]
        for activity in ActivityInfo.all {
            var difficulties: [String: Int] = [:]
            for difficulty in GameDifficulty.allCases {
                difficulties[difficulty.rawValue] = 0
            }
            result[activity.id] = difficulties
        }
        return result
    }

    private func saveDictionary<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func loadDictionary<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private static func date(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
