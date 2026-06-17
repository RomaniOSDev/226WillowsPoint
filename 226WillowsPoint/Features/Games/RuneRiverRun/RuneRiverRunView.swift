import SwiftUI

struct RuneRiverRunView: View {
    @EnvironmentObject private var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @StateObject private var viewModel: RuneRiverRunViewModel
    @State private var canvasSize: CGSize = .zero
    @State private var showNextLevel = false

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
        _viewModel = StateObject(wrappedValue: RuneRiverRunViewModel(
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
          onRetry: { viewModel.retry(canvasSize: canvasSize) },
          onBackToLevels: { dismiss() }
        )
      case .failed:
        GameResultView(
          isSuccess: false,
          stars: 0,
          primaryMetric: "—",
          metricLabel: "Path Lost",
          showNextLevel: false,
          newlyUnlockedAchievement: nil,
          onNextLevel: {},
          onRetry: { viewModel.retry(canvasSize: canvasSize) },
          onBackToLevels: { dismiss() }
        )
      }
    }
    .navigationBarBackButtonHidden(viewModel.phase != .playing)
    .navigationDestination(isPresented: $showNextLevel) {
      RuneRiverRunView(activityId: activityId, difficulty: difficulty, level: level + 1)
    }
    .onDisappear { viewModel.stopGame() }
  }

  private var gameContent: some View {
    GeometryReader { geo in
      ZStack {
        BackgroundPatternView()

        Canvas { context, size in
          if viewModel.pathPoints.count > 1 {
            var path = Path()
            path.move(to: viewModel.pathPoints[0])
            for point in viewModel.pathPoints.dropFirst() {
              path.addLine(to: point)
            }
            context.stroke(path, with: .color(Color("AppPrimary").opacity(0.4)), style: StrokeStyle(lineWidth: 6, lineCap: .round))
          }

          for obstacle in viewModel.obstacles {
            let rect = CGRect(
              x: obstacle.position.x - obstacle.radius,
              y: obstacle.position.y - obstacle.radius,
              width: obstacle.radius * 2,
              height: obstacle.radius * 2
            )
            context.fill(Path(ellipseIn: rect), with: .color(Color("AppSurface")))
            context.stroke(Path(ellipseIn: rect), with: .color(Color("AppTextSecondary")), lineWidth: 2)
          }

          for checkpoint in viewModel.checkpoints {
            let radius: CGFloat = 20
            let rect = CGRect(
              x: checkpoint.position.x - radius,
              y: checkpoint.position.y - radius,
              width: radius * 2,
              height: radius * 2
            )
            let color = checkpoint.isActivated ? Color("AppAccent") : Color("AppPrimary").opacity(0.6)
            context.fill(Path(ellipseIn: rect), with: .color(color))
            context.stroke(Path(ellipseIn: rect), with: .color(Color("AppAccent")), lineWidth: 1.5)
          }
        }
        .offset(x: viewModel.shakeOffset)

        Circle()
          .fill(
            RadialGradient(
              colors: [Color("AppAccent"), Color("AppPrimary")],
              center: .center,
              startRadius: 0,
              endRadius: 20
            )
          )
          .overlay {
            Circle()
              .stroke(Color("AppAccent").opacity(0.65), lineWidth: 2)
          }
          .frame(width: 30, height: 30)
          .position(viewModel.orbPosition)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                viewModel.updateOrbPosition(value.location)
              }
          )
          .offset(x: viewModel.shakeOffset)

        VStack {
          GameTopHUD(
            leading: "Time: \(viewModel.formattedTime)",
            trailing: "Runes: \(viewModel.checkpoints.filter(\.isActivated).count)/\(viewModel.checkpoints.count)"
          )
          Spacer()
        }

        FailFlashOverlay(isVisible: $viewModel.showFailFlash)
      }
      .onAppear {
        canvasSize = geo.size
        viewModel.startGame(canvasSize: geo.size)
      }
    }
  }

  private func achievementForId(_ id: String?) -> Achievement? {
    guard let id else { return nil }
    return Achievement.all(from: storage).first { $0.id == id }
  }
}
