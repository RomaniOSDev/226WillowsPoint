import Foundation
import Combine
import SwiftUI

enum RuneTrailPhase {
    case playing
    case success
    case failed
}

final class RuneTrailViewModel: ObservableObject {
    struct RuneItem: Identifiable {
        let id: UUID
        var position: CGPoint
        var isActive: Bool
        var isVisible: Bool
        var isPermanentlyActivated: Bool
        var fadeDeadline: Date?
    }

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @Published var phase: RuneTrailPhase = .playing
    @Published var runes: [RuneItem] = []
    @Published var activatedLines: [(CGPoint, CGPoint)] = []
    @Published var elapsedSeconds: Int = 0
    @Published var showFailFlash = false
    @Published var earnedStars: Int = 0
    @Published var newlyUnlockedAchievementId: String?

    private var totalRunesNeeded: Int { difficulty.runeTrailCount + level }
    private var activatedCount = 0
    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var startTime = Date()
    private var lastTapTime: Date?
    private let timeLimit = 30

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
    }

    func startGame(screenSize: CGSize) {
        phase = .playing
        runes = []
        activatedLines = []
        activatedCount = 0
        elapsedSeconds = 0
        earnedStars = 0
        startTime = Date()
        spawnInitialRunes(screenSize: screenSize)
        startTimers(screenSize: screenSize)
    }

    func stopGame() {
        gameTimer?.cancel()
        spawnTimer?.cancel()
    }

    func tapRune(_ rune: RuneItem, center: CGPoint, screenSize: CGSize) {
        guard phase == .playing else { return }

        if let lastTap = lastTapTime, Date().timeIntervalSince(lastTap) < 0.15 {
            return
        }
        lastTapTime = Date()

        guard let index = runes.firstIndex(where: { $0.id == rune.id }) else { return }
        guard runes[index].isVisible else { return }

        HapticManager.mediumTap()

        if runes[index].isPermanentlyActivated {
            return
        }

        runes[index].isPermanentlyActivated = true
        runes[index].isVisible = false
        activatedLines.append((runes[index].position, center))
        activatedCount += 1

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            runes[index].isActive = true
        }

        if activatedCount >= totalRunesNeeded {
            completeSuccess()
        } else {
            spawnRune(screenSize: screenSize)
        }
    }

    func missRune(_ runeId: UUID) {
        guard phase == .playing else { return }
        guard let index = runes.firstIndex(where: { $0.id == runeId }) else { return }
        guard runes[index].isVisible, !runes[index].isPermanentlyActivated else { return }

        runes[index].isVisible = false
        resetProgress()
    }

    func retry(screenSize: CGSize) {
        stopGame()
        startGame(screenSize: screenSize)
    }

    private func resetProgress() {
        HapticManager.error()
        activatedCount = 0
        activatedLines = []
        for i in runes.indices {
            runes[i].isPermanentlyActivated = false
            runes[i].isActive = false
        }
    }

    private func completeSuccess() {
        stopGame()
        let elapsed = Int(Date().timeIntervalSince(startTime))
        earnedStars = calculateStars(elapsed: elapsed)
        phase = .success
        HapticManager.success()
        SoundManager.playSuccess()

        let achievementId = AppStorage.shared.recordLevelCompletion(
            activityId: activityId,
            difficulty: difficulty,
            level: level,
            stars: earnedStars,
            playTimeSeconds: elapsed,
            isDailyChallenge: isDailyChallenge
        )
        newlyUnlockedAchievementId = achievementId
    }

    private func failGame() {
        stopGame()
        phase = .failed
        showFailFlash = true
        HapticManager.error()
        SoundManager.playFail()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showFailFlash = false
        }
    }

    private func calculateStars(elapsed: Int) -> Int {
        if elapsed < 10 { return 3 }
        if elapsed < 15 { return 2 }
        if elapsed < 20 { return 1 }
        return 1
    }

    private func startTimers(screenSize: CGSize) {
        gameTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                elapsedSeconds = Int(Date().timeIntervalSince(startTime))
                if elapsedSeconds >= timeLimit {
                    failGame()
                }
                checkFadingRunes(screenSize: screenSize)
            }

        spawnTimer = Timer.publish(every: 2.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, phase == .playing else { return }
                let visibleCount = runes.filter { $0.isVisible && !$0.isPermanentlyActivated }.count
                let maxVisible = difficulty.runeTrailCount
                if visibleCount < maxVisible && activatedCount < totalRunesNeeded {
                    spawnRune(screenSize: screenSize)
                }
            }
    }

    private func checkFadingRunes(screenSize: CGSize) {
        let now = Date()
        for i in runes.indices {
            if runes[i].isVisible && !runes[i].isPermanentlyActivated,
               let deadline = runes[i].fadeDeadline, now >= deadline {
                missRune(runes[i].id)
            }
        }
    }

    private func spawnInitialRunes(screenSize: CGSize) {
        let count = min(difficulty.runeTrailCount, totalRunesNeeded)
        for _ in 0..<count {
            spawnRune(screenSize: screenSize)
        }
    }

    private func spawnRune(screenSize: CGSize) {
        let margin: CGFloat = 50
        let center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let edge = Int.random(in: 0..<4)
        var position: CGPoint
        switch edge {
        case 0:
            position = CGPoint(x: CGFloat.random(in: margin...(screenSize.width - margin)), y: margin)
        case 1:
            position = CGPoint(x: screenSize.width - margin, y: CGFloat.random(in: margin...(screenSize.height - margin)))
        case 2:
            position = CGPoint(x: CGFloat.random(in: margin...(screenSize.width - margin)), y: screenSize.height - margin - 100)
        default:
            position = CGPoint(x: margin, y: CGFloat.random(in: margin...(screenSize.height - margin)))
        }

        let distance = hypot(position.x - center.x, position.y - center.y)
        if distance < 130 { return }

        let fadeDuration = Double.random(in: 2...5)
        let rune = RuneItem(
            id: UUID(),
            position: position,
            isActive: false,
            isVisible: true,
            isPermanentlyActivated: false,
            fadeDeadline: Date().addingTimeInterval(fadeDuration)
        )
        runes.append(rune)
    }

    var formattedTime: String {
        let remaining = max(0, timeLimit - elapsedSeconds)
        return "\(remaining)s"
    }
}

private extension GameDifficulty {
    var runeTrailCount: Int {
        switch self {
        case .easy: return 3
        case .normal: return 5
        case .hard: return 8
        }
    }
}
