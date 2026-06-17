import SwiftUI

struct RuneRhythmQuestView: View {
    @EnvironmentObject private var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    let isDailyChallenge: Bool

    @StateObject private var viewModel: RuneRhythmQuestViewModel
    @State private var screenSize: CGSize = .zero
    @State private var showNextLevel = false

    init(activityId: String, difficulty: GameDifficulty, level: Int, isDailyChallenge: Bool = false) {
        self.activityId = activityId
        self.difficulty = difficulty
        self.level = level
        self.isDailyChallenge = isDailyChallenge
        _viewModel = StateObject(wrappedValue: RuneRhythmQuestViewModel(
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
          metricLabel: "Time Remaining",
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
      RuneRhythmQuestView(activityId: activityId, difficulty: difficulty, level: level + 1)
    }
    .onDisappear { viewModel.stopGame() }
  }

  private var gameContent: some View {
    TimelineView(.animation(minimumInterval: 0.05)) { _ in
      GeometryReader { geo in
        ZStack {
          BackgroundPatternView()

          if viewModel.pathwayOpen {
            Canvas { context, size in
              var path = Path()
              path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.5))
              path.addCurve(
                to: CGPoint(x: size.width * 0.9, y: size.height * 0.3),
                control1: CGPoint(x: size.width * 0.4, y: size.height * 0.2),
                control2: CGPoint(x: size.width * 0.6, y: size.height * 0.7)
              )
              context.stroke(path, with: .color(Color("AppAccent")), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
          }

          ForEach(viewModel.runes) { rune in
            RhythmRuneView(
              rune: rune,
              isCurrent: rune.id == viewModel.currentSequenceIndex,
              onPressStart: { viewModel.beginCharge(runeId: rune.id) },
              onPressEnd: { viewModel.endCharge(runeId: rune.id) }
            )
          }

          VStack {
            GameTopHUD(
              leading: "Time: \(viewModel.formattedTime)",
              trailing: "Sequence: \(viewModel.currentSequenceIndex)/\(viewModel.runes.count)",
              subtitle: "Long-press runes in order"
            )
            Spacer()
          }

          FailFlashOverlay(isVisible: $viewModel.showFailFlash)
        }
        .onAppear {
          screenSize = geo.size
          viewModel.startGame(screenSize: geo.size)
        }
      }
    }
  }

  private func achievementForId(_ id: String?) -> Achievement? {
    guard let id else { return nil }
    return Achievement.all(from: storage).first { $0.id == id }
  }
}

struct RhythmRuneView: View {
    let rune: RuneRhythmQuestViewModel.RhythmRune
    let isCurrent: Bool
    let onPressStart: () -> Void
    let onPressEnd: () -> Void

    @State private var isHolding = false

  var body: some View {
    ZStack {
      Circle()
        .fill(Color("AppSurface"))
        .frame(width: 56, height: 56)

      Circle()
        .trim(from: 0, to: rune.chargeProgress)
        .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .frame(width: 56, height: 56)
        .rotationEffect(.degrees(-90))

      Circle()
        .fill(rune.isActivated ? Color("AppPrimary") : Color("AppPrimary").opacity(isCurrent ? 0.6 : 0.2))
        .frame(width: 40, height: 40)

      if rune.isActivated {
        Image(systemName: "checkmark")
          .font(.caption.bold())
          .foregroundStyle(Color("AppBackground"))
      }
    }
    .frame(width: 56, height: 56)
    .contentShape(Circle())
    .position(rune.position)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          if !isHolding {
            isHolding = true
            onPressStart()
          }
        }
        .onEnded { _ in
          if isHolding {
            isHolding = false
            onPressEnd()
          }
        }
    )
  }
}
