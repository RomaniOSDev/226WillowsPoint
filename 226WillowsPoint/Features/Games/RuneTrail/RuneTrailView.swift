import SwiftUI

struct RuneTrailView: View {
    @EnvironmentObject private var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @StateObject private var viewModel: RuneTrailViewModel
    @State private var screenSize: CGSize = .zero
    @State private var showNextLevel = false

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
        _viewModel = StateObject(wrappedValue: RuneTrailViewModel(
            activityId: activityId,
            difficulty: difficulty,
            level: level,
            isDailyChallenge: isDailyChallenge
        ))
    }

  var body: some View {
    Group {
      switch viewModel.phase {
      case .playing:
        gameContent
      case .success:
        GameResultView(
          isSuccess: true,
          stars: viewModel.earnedStars,
          primaryMetric: viewModel.formattedTime,
          metricLabel: "Completion Time",
          showNextLevel: level < 4 && !isDailyChallenge,
          newlyUnlockedAchievement: achievementForId(viewModel.newlyUnlockedAchievementId),
          onNextLevel: { showNextLevel = true },
          onRetry: { viewModel.retry(screenSize: screenSize) },
          onBackToLevels: { dismiss() }
        )
      case .failed:
        GameResultView(
          isSuccess: false,
          stars: 0,
          primaryMetric: "—",
          metricLabel: "Time Expired",
          showNextLevel: false,
          newlyUnlockedAchievement: nil,
          onNextLevel: {},
          onRetry: { viewModel.retry(screenSize: screenSize) },
          onBackToLevels: { dismiss() }
        )
      }
    }
    .navigationBarBackButtonHidden(viewModel.phase != .playing)
    .navigationDestination(isPresented: $showNextLevel) {
      RuneTrailView(activityId: activityId, difficulty: difficulty, level: level + 1)
    }
    .onDisappear { viewModel.stopGame() }
  }

  private var gameContent: some View {
    GeometryReader { geo in
      ZStack {
        BackgroundPatternView()

        Canvas { context, size in
          let center = CGPoint(x: size.width / 2, y: size.height / 2)
          for line in viewModel.activatedLines {
            var path = Path()
            path.move(to: line.0)
            path.addLine(to: line.1)
            context.stroke(path, with: .color(Color("AppAccent")), style: StrokeStyle(lineWidth: 2, lineCap: .round))
          }

          let stoneRect = CGRect(x: center.x - 100, y: center.y - 100, width: 200, height: 200)
          context.fill(Path(ellipseIn: stoneRect), with: .color(Color("AppSurface")))
          context.stroke(Path(ellipseIn: stoneRect), with: .color(Color("AppPrimary").opacity(0.6)), lineWidth: 3)

          for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let innerR: CGFloat = 60
            let outerR: CGFloat = 90
            var runePath = Path()
            runePath.move(to: CGPoint(x: center.x + cos(angle) * innerR, y: center.y + sin(angle) * innerR))
            runePath.addLine(to: CGPoint(x: center.x + cos(angle) * outerR, y: center.y + sin(angle) * outerR))
            context.stroke(runePath, with: .color(Color("AppPrimary").opacity(0.3)), lineWidth: 1.5)
          }
        }

        ForEach(viewModel.runes.filter { $0.isVisible && !$0.isPermanentlyActivated }) { rune in
          RuneTapTarget(rune: rune) {
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            viewModel.tapRune(rune, center: center, screenSize: geo.size)
          }
        }

        VStack {
          GameTopHUD(
            leading: "Time: \(viewModel.formattedTime)",
            trailing: "Runes: \(viewModel.activatedLines.count)"
          )
          Spacer()
        }

        FailFlashOverlay(isVisible: $viewModel.showFailFlash)
      }
      .onAppear {
        screenSize = geo.size
        viewModel.startGame(screenSize: geo.size)
      }
      .onChange(of: geo.size) { newSize in
        screenSize = newSize
      }
    }
  }

  private func achievementForId(_ id: String?) -> Achievement? {
    guard let id else { return nil }
    return Achievement.all(from: storage).first { $0.id == id }
  }
}

struct RuneTapTarget: View {
    let rune: RuneTrailViewModel.RuneItem
    let onTap: () -> Void

    @State private var opacity: Double = 0.3

  var body: some View {
    Button(action: onTap) {
      ZStack {
        Circle()
          .fill(Color("AppPrimary").opacity(opacity))
          .frame(width: 44, height: 44)
        Circle()
          .stroke(Color("AppAccent"), lineWidth: 2)
          .frame(width: 44, height: 44)
      }
    }
    .position(rune.position)
    .onAppear {
      withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
        opacity = 1.0
      }
    }
  }
}
