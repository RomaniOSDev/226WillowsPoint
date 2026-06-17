import Foundation
import Combine
import SwiftUI

enum RuneRhythmPhase {
    case playing
    case success
    case failed
}

final class RuneRhythmQuestViewModel: ObservableObject {
    struct RhythmRune: Identifiable {
        let id: Int
        let position: CGPoint
        var chargeProgress: CGFloat
        var isActivated: Bool
        var isCharging: Bool
        var requiredHold: TimeInterval
    }

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @Published var phase: RuneRhythmPhase = .playing
    @Published var runes: [RhythmRune] = []
    @Published var currentSequenceIndex = 0
    @Published var elapsedSeconds: Int = 0
    @Published var showFailFlash = false
    @Published var earnedStars: Int = 0
    @Published var newlyUnlockedAchievementId: String?
    @Published var pathwayOpen = false

    private var gameTimer: AnyCancellable?
    private var chargeTimer: AnyCancellable?
    private var chargeStartTime: Date?
    private var chargingRuneId: Int?
    private var startTime = Date()
    private let timeLimit = 60

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
    }

    func startGame(screenSize: CGSize) {
        phase = .playing
        elapsedSeconds = 0
        earnedStars = 0
        currentSequenceIndex = 0
        pathwayOpen = false
        showFailFlash = false
        startTime = Date()
        runes = generateRunes(screenSize: screenSize)
        startTimer()
    }

    func stopGame() {
        gameTimer?.cancel()
        stopChargeTimer()
    }

    func beginCharge(runeId: Int) {
        guard phase == .playing else { return }
        guard runeId == currentSequenceIndex else {
            resetAllRunes()
            return
        }
        guard runeId < runes.count, !runes[runeId].isActivated else { return }
        guard chargingRuneId == nil else { return }

        chargingRuneId = runeId
        chargeStartTime = Date()
        runes[runeId].isCharging = true
        HapticManager.mediumTap()
        startChargeTimer()
    }

    func updateCharge() {
        guard let runeId = chargingRuneId, let start = chargeStartTime else { return }
        guard runeId < runes.count else { return }

        let elapsed = Date().timeIntervalSince(start)
        let required = runes[runeId].requiredHold
        let minHold = required * 0.7
        let progress = min(1.0, CGFloat(elapsed / required))
        runes[runeId].chargeProgress = progress

        if elapsed >= minHold && progress >= 1.0 {
            activateRune(runeId)
            return
        }

        if elapsed > required + 0.5 {
            resetAllRunes()
        }
    }

    func endCharge(runeId: Int) {
        stopChargeTimer()
        guard let start = chargeStartTime, chargingRuneId == runeId else { return }
        guard runeId < runes.count else { return }

        let elapsed = Date().timeIntervalSince(start)
        let required = runes[runeId].requiredHold
        let minHold = required * 0.7

        runes[runeId].isCharging = false
        chargingRuneId = nil
        chargeStartTime = nil

        if elapsed >= minHold && elapsed <= required + 0.3 {
            activateRune(runeId)
        } else {
            resetAllRunes()
        }
    }

    private func activateRune(_ runeId: Int) {
        guard runeId < runes.count, !runes[runeId].isActivated else { return }

        stopChargeTimer()
        runes[runeId].isCharging = false
        runes[runeId].isActivated = true
        runes[runeId].chargeProgress = 1.0
        chargingRuneId = nil
        chargeStartTime = nil

        HapticManager.mediumTap()
        currentSequenceIndex += 1

        if currentSequenceIndex >= runes.count {
            completeSuccess()
        }
    }

    private func startChargeTimer() {
        chargeTimer?.cancel()
        chargeTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCharge()
            }
    }

    private func stopChargeTimer() {
        chargeTimer?.cancel()
        chargeTimer = nil
    }

    func retry(screenSize: CGSize) {
        stopGame()
        startGame(screenSize: screenSize)
    }

    private func resetAllRunes() {
        stopChargeTimer()
        chargingRuneId = nil
        chargeStartTime = nil

        for i in runes.indices {
            runes[i].isActivated = false
            runes[i].chargeProgress = 0
            runes[i].isCharging = false
        }
        currentSequenceIndex = 0
        HapticManager.error()
    }

    private func completeSuccess() {
        stopGame()
        pathwayOpen = true
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
        if elapsed < 30 { return 3 }
        if elapsed < 45 { return 2 }
        if elapsed < 60 { return 1 }
        return 1
    }

    private func startTimer() {
        gameTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                elapsedSeconds = Int(Date().timeIntervalSince(startTime))
                if elapsedSeconds >= timeLimit {
                    failGame()
                }
            }
    }

    private func generateRunes(screenSize: CGSize) -> [RhythmRune] {
        let count = 3 + level
        let holdDuration = difficulty.maxHoldDuration - Double(level) * 0.1
        var positions: [CGPoint] = []
        let margin: CGFloat = 60

        for i in 0..<count {
            let row = i / 2
            let col = i % 2
            let x = margin + CGFloat(col) * (screenSize.width - margin * 2) / max(1, CGFloat(count / 2))
            let y = margin + 80 + CGFloat(row) * 100
            positions.append(CGPoint(x: min(x, screenSize.width - margin), y: min(y, screenSize.height - 150)))
        }

        return positions.enumerated().map { index, pos in
            RhythmRune(
                id: index,
                position: pos,
                chargeProgress: 0,
                isActivated: false,
                isCharging: false,
                requiredHold: max(1.5, holdDuration)
            )
        }
    }

    var formattedTime: String {
        let remaining = max(0, timeLimit - elapsedSeconds)
        return "\(remaining)s"
    }
}

private extension GameDifficulty {
    var maxHoldDuration: TimeInterval {
        switch self {
        case .easy: return 3.0
        case .normal: return 2.5
        case .hard: return 2.0
        }
    }
}
