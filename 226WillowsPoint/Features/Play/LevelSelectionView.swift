import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject private var storage: AppStorage
    let activity: ActivityInfo

    @State private var selectedDifficulty: GameDifficulty = .easy

    private var starsPerDifficulty: [GameDifficulty: Int] {
        var result: [GameDifficulty: Int] = [:]
        for difficulty in GameDifficulty.allCases {
            result[difficulty] = storage.starsForDifficulty(activityId: activity.id, difficulty: difficulty)
        }
        return result
    }

    private var difficultyProgress: Double {
        let completed = (0..<5).filter {
            storage.stars(for: activity.id, difficulty: selectedDifficulty, level: $0) >= 1
        }.count
        return Double(completed) / 5.0
    }

    private var bestLevelIndex: Int? {
        var best = -1
        var bestStars = 0
        for level in 0..<5 {
            let s = storage.stars(for: activity.id, difficulty: selectedDifficulty, level: level)
            if s > bestStars {
                bestStars = s
                best = level
            }
        }
        return best >= 0 ? best : nil
    }

  var body: some View {
    ZStack {
      BackgroundPatternView()

      ScrollView {
        VStack(spacing: 20) {
          activityHeader

          CustomDifficultyPicker(
            selection: $selectedDifficulty,
            starsPerDifficulty: starsPerDifficulty
          )

          difficultySummary

          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(0..<5, id: \.self) { level in
              levelCell(level: level)
            }
          }
        }
        .padding(16)
        .padding(.bottom, 24)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: LevelRoute.self) { route in
      GameViewFactory.view(for: route)
    }
  }

  private var activityHeader: some View {
    HStack(spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(Color("AppPrimary").opacity(0.15))
          .frame(width: 56, height: 56)
        Image(systemName: activity.iconName)
          .font(.title2)
          .foregroundStyle(Color("AppPrimary"))
      }
      VStack(alignment: .leading, spacing: 4) {
        Text(activity.title)
          .font(.title2.bold())
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Text(activity.subtitle)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)
      }
      Spacer()
      ProgressRingView(progress: Double(storage.completedLevelsCount(activityId: activity.id)) / 15.0, size: 48)
    }
    .padding(14)
    .depthCard(cornerRadius: 18, elevation: .raised)
  }

  private var difficultySummary: some View {
    CustomCard {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("\(selectedDifficulty.displayName) Progress")
            .font(.caption.bold())
            .foregroundStyle(Color("AppTextSecondary"))
          Text("\(Int(difficultyProgress * 100))% complete")
            .font(.subheadline.bold())
            .foregroundStyle(Color("AppTextPrimary"))
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text("\(starsPerDifficulty[selectedDifficulty] ?? 0)")
            .font(.title3.bold())
            .foregroundStyle(Color("AppPrimary"))
          Text("STARS")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color("AppTextSecondary"))
        }
      }
      .padding(14)
    }
  }

  @ViewBuilder
  private func levelCell(level: Int) -> some View {
    let unlocked = storage.isLevelUnlocked(activityId: activity.id, difficulty: selectedDifficulty, level: level)
    let stars = storage.stars(for: activity.id, difficulty: selectedDifficulty, level: level)
    let isBest = bestLevelIndex == level && stars > 0

    if unlocked {
      NavigationLink(value: LevelRoute(activityId: activity.id, difficulty: selectedDifficulty, level: level)) {
        LevelGridCell(level: level, stars: stars, isLocked: false, isBest: isBest)
      }
      .buttonStyle(.plain)
      .simultaneousGesture(TapGesture().onEnded {
        HapticManager.mediumTap()
      })
    } else {
      LevelGridCell(level: level, stars: stars, isLocked: true, isBest: false)
    }
  }
}

struct LevelRoute: Hashable, Identifiable {
    let activityId: String
    let difficulty: GameDifficulty
    let level: Int
    var isDailyChallenge: Bool = false

    var id: String {
        let base = "\(activityId)-\(difficulty.rawValue)-\(level)"
        return isDailyChallenge ? "daily-\(base)" : base
    }
}
