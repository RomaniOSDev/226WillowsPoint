import Foundation
import Combine
import SwiftUI

enum RuneRiverPhase {
    case playing
    case success
    case failed
}

final class RuneRiverRunViewModel: ObservableObject {
    struct Checkpoint: Identifiable {
        let id: Int
        var position: CGPoint
        var isActivated: Bool
        var moveDeadline: Date?
    }

    struct Obstacle: Identifiable {
        let id: Int
        let position: CGPoint
        let radius: CGFloat
    }

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @Published var phase: RuneRiverPhase = .playing
    @Published var orbPosition: CGPoint = .zero
    @Published var checkpoints: [Checkpoint] = []
    @Published var obstacles: [Obstacle] = []
    @Published var pathPoints: [CGPoint] = []
    @Published var elapsedSeconds: Int = 0
    @Published var showFailFlash = false
    @Published var shakeOffset: CGFloat = 0
    @Published var earnedStars: Int = 0
    @Published var newlyUnlockedAchievementId: String?
    @Published var isOnPath = true

    private var currentCheckpointIndex = 0
    private var gameTimer: AnyCancellable?
    private var checkpointTimer: AnyCancellable?
    private var startTime = Date()
    private let gridWidth: CGFloat = 300
    private let gridHeight: CGFloat = 600

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
    }

    func startGame(canvasSize: CGSize) {
        phase = .playing
        elapsedSeconds = 0
        earnedStars = 0
        currentCheckpointIndex = 0
        showFailFlash = false
        startTime = Date()

        let scale = min(canvasSize.width / (gridWidth + 40), (canvasSize.height - 120) / (gridHeight + 40))
        let offsetX = (canvasSize.width - gridWidth * scale) / 2
        let offsetY = 80.0

        pathPoints = generatePath(scale: scale, offsetX: offsetX, offsetY: offsetY)
        orbPosition = pathPoints.first ?? .zero
        checkpoints = generateCheckpoints(scale: scale, offsetX: offsetX, offsetY: offsetY)
        obstacles = generateObstacles(scale: scale, offsetX: offsetX, offsetY: offsetY)

        startTimers()
    }

    func stopGame() {
        gameTimer?.cancel()
        checkpointTimer?.cancel()
    }

    func updateOrbPosition(_ location: CGPoint) {
        guard phase == .playing else { return }

        let nearest = nearestPathPoint(to: location)
        let distance = hypot(location.x - nearest.x, location.y - nearest.y)

        if distance > 30 {
            isOnPath = false
            failGame()
            return
        }

        isOnPath = true
        orbPosition = nearest
        HapticManager.mediumTap()
        checkCheckpointProximity()
        checkObstacleCollision()
    }

    func retry(canvasSize: CGSize) {
        stopGame()
        startGame(canvasSize: canvasSize)
    }

    private func checkCheckpointProximity() {
        guard currentCheckpointIndex < checkpoints.count else {
            if currentCheckpointIndex >= checkpoints.count {
                completeSuccess()
            }
            return
        }

        let checkpoint = checkpoints[currentCheckpointIndex]
        let distance = hypot(orbPosition.x - checkpoint.position.x, orbPosition.y - checkpoint.position.y)

        if distance < 30 && !checkpoint.isActivated {
            checkpoints[currentCheckpointIndex].isActivated = true
            HapticManager.mediumTap()
            currentCheckpointIndex += 1

            if currentCheckpointIndex >= checkpoints.count {
                completeSuccess()
            } else {
                resetCheckpointTimer()
            }
        }
    }

    private func checkObstacleCollision() {
        for obstacle in obstacles {
            let distance = hypot(orbPosition.x - obstacle.position.x, orbPosition.y - obstacle.position.y)
            if distance < obstacle.radius + 15 {
                failGame()
                return
            }
        }
    }

    private func resetCheckpointTimer() {
        guard currentCheckpointIndex < checkpoints.count else { return }
        let window: TimeInterval = difficulty == .hard ? 2.0 : 3.0
        checkpoints[currentCheckpointIndex].moveDeadline = Date().addingTimeInterval(window)
    }

    private func checkCheckpointTimeout() {
        guard phase == .playing, currentCheckpointIndex < checkpoints.count else { return }
        let checkpoint = checkpoints[currentCheckpointIndex]
        if let deadline = checkpoint.moveDeadline, Date() >= deadline, !checkpoint.isActivated {
            moveCheckpoint(index: currentCheckpointIndex)
            resetCheckpointTimer()
        }
    }

    private func moveCheckpoint(index: Int) {
        guard index < checkpoints.count else { return }
        let offsetX = CGFloat.random(in: -20...20)
        let offsetY = CGFloat.random(in: -20...20)
        checkpoints[index].position.x += offsetX
        checkpoints[index].position.y += offsetY
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
        guard phase == .playing else { return }
        stopGame()
        phase = .failed
        showFailFlash = true
        withAnimation(.default.repeatCount(3, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showFailFlash = false
            self?.shakeOffset = 0
        }
        HapticManager.error()
        SoundManager.playFail()
    }

    private func calculateStars(elapsed: Int) -> Int {
        if elapsed < 60 { return 3 }
        if elapsed < 120 { return 2 }
        if elapsed < 180 { return 1 }
        return 1
    }

    private func startTimers() {
        gameTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                elapsedSeconds = Int(Date().timeIntervalSince(startTime))
            }

        checkpointTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkCheckpointTimeout()
            }

        resetCheckpointTimer()
    }

    private func generatePath(scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        let steps = 40 + level * 5
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = t * gridWidth
            let y = gridHeight * (0.2 + 0.6 * t) + sin(t * .pi * 3) * 40
            points.append(CGPoint(x: offsetX + x * scale, y: offsetY + y * scale))
        }
        return points
    }

    private func generateCheckpoints(scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> [Checkpoint] {
        let count = 3 + level
        var result: [Checkpoint] = []
        for i in 0..<count {
            let t = CGFloat(i + 1) / CGFloat(count + 1)
            let x = t * gridWidth
            let y = gridHeight * (0.2 + 0.6 * t) + sin(t * .pi * 3) * 40
            result.append(Checkpoint(
                id: i,
                position: CGPoint(x: offsetX + x * scale, y: offsetY + y * scale),
                isActivated: false,
                moveDeadline: nil
            ))
        }
        return result
    }

    private func generateObstacles(scale: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> [Obstacle] {
        let density = difficulty.obstacleDensity
        let totalCells = 20
        let obstacleCount = Int(CGFloat(totalCells) * density) + level
        var result: [Obstacle] = []
        for i in 0..<obstacleCount {
            let t = CGFloat.random(in: 0.1...0.9)
            let x = t * gridWidth + CGFloat.random(in: -30...30)
            let y = gridHeight * (0.2 + 0.6 * t) + CGFloat.random(in: -40...40)
            result.append(Obstacle(
                id: i,
                position: CGPoint(x: offsetX + x * scale, y: offsetY + y * scale),
                radius: 18 * scale
            ))
        }
        return result
    }

    private func nearestPathPoint(to point: CGPoint) -> CGPoint {
        pathPoints.min(by: {
            hypot($0.x - point.x, $0.y - point.y) < hypot($1.x - point.x, $1.y - point.y)
        }) ?? point
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private extension GameDifficulty {
    var obstacleDensity: CGFloat {
        switch self {
        case .easy: return 0.03
        case .normal: return 0.10
        case .hard: return 0.20
        }
    }
}
