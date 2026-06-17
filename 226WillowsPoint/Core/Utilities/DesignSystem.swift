import SwiftUI

// MARK: - Card & Layout

struct CustomCard<Content: View>: View {
    var glow: Bool = false
    var elevation: DepthElevation = .raised
    @ViewBuilder let content: Content

  var body: some View {
    content
      .depthCard(cornerRadius: 18, elevation: elevation, glow: glow)
      .depthTopSheen(cornerRadius: 18)
  }
}

struct ScreenHeaderView: View {
    let title: String
    let subtitle: String
    var badge: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 6) {
          Text(title)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)

          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(Color("AppTextSecondary"))
            .fixedSize(horizontal: false, vertical: true)
        }
        Spacer(minLength: 8)
        if let badge {
          GradientBadge(text: badge)
        }
      }
      Capsule()
        .fill(AppGradients.primary)
        .frame(height: 3)
        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 4, y: 1)
    }
  }
}

struct SectionHeaderView: View {
    let title: String
    var trailing: String?

  var body: some View {
    HStack {
      Text(title)
        .font(.headline)
        .foregroundStyle(Color("AppTextPrimary"))
      Spacer()
      if let trailing {
        Text(trailing)
          .font(.caption.bold())
          .foregroundStyle(Color("AppAccent"))
      }
    }
  }
}

// MARK: - Stats & Progress

struct StatPillCell: View {
    let icon: String
    let value: String
    let label: String
    var accent: Bool = false

  var body: some View {
    VStack(spacing: 6) {
      ZStack {
        Circle()
          .fill(accent ? Color("AppPrimary").opacity(0.2) : Color("AppBackground").opacity(0.5))
          .frame(width: 36, height: 36)
        Image(systemName: icon)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(accent ? Color("AppPrimary") : Color("AppTextSecondary"))
      }
      Text(value)
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundStyle(Color("AppTextPrimary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .padding(.horizontal, 6)
    .depthTile(cornerRadius: 14, glow: accent)
  }
}

struct ProgressRingView: View {
    let progress: Double
    var lineWidth: CGFloat = 4
    var size: CGFloat = 52
    var showLabel: Bool = true

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color("AppTextSecondary").opacity(0.2), lineWidth: lineWidth)
      Circle()
        .trim(from: 0, to: min(1, max(0, progress)))
        .stroke(
          AppGradients.ring,
          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
      if showLabel {
        Text("\(Int(progress * 100))%")
          .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
          .foregroundStyle(Color("AppTextPrimary"))
      }
    }
    .frame(width: size, height: size)
  }
}

struct LinearProgressBar: View {
    let progress: Double
    var height: CGFloat = 6

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color("AppTextSecondary").opacity(0.15))
        Capsule()
          .fill(AppGradients.progress)
          .frame(width: geo.size.width * min(1, max(0, progress)))
      }
    }
    .frame(height: height)
  }
}

// MARK: - Activity & Level Cells

struct ActivityCardCell: View {
    let activity: ActivityInfo
    let stars: Int
    let levelsCompleted: Int
    let totalLevels: Int

  var body: some View {
    HStack(spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [Color("AppPrimary").opacity(0.25), Color("AppAccent").opacity(0.1)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 62, height: 62)
        Image(systemName: activity.iconName)
          .font(.title2)
          .foregroundStyle(Color("AppPrimary"))
      }

      VStack(alignment: .leading, spacing: 6) {
        Text(activity.title)
          .font(.headline)
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)

        Text(activity.subtitle)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)

        HStack(spacing: 8) {
          HStack(spacing: 3) {
            Image(systemName: "star.fill")
              .font(.system(size: 10))
              .foregroundStyle(Color("AppPrimary"))
            Text("\(stars) STARS")
              .font(.system(size: 10, weight: .bold))
              .foregroundStyle(Color("AppAccent"))
          }
          Text("·")
            .foregroundStyle(Color("AppTextSecondary"))
          Text("\(levelsCompleted)/\(totalLevels) levels")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(Color("AppTextSecondary"))
        }
        LinearProgressBar(progress: totalLevels > 0 ? Double(levelsCompleted) / Double(totalLevels) : 0, height: 4)
      }

      Image(systemName: "chevron.right")
        .font(.caption.bold())
        .foregroundStyle(Color("AppPrimary"))
    }
    .padding(16)
    .depthCard(cornerRadius: 18, elevation: .raised)
    .depthTopSheen(cornerRadius: 18)
  }
}

struct LevelGridCell: View {
    let level: Int
    let stars: Int
    let isLocked: Bool
    let isBest: Bool

  var body: some View {
    VStack(spacing: 10) {
      ZStack {
        if isLocked {
          Circle()
            .fill(Color("AppTextSecondary").opacity(0.12))
            .frame(width: 48, height: 48)
          Image(systemName: "lock.fill")
            .font(.body)
            .foregroundStyle(Color("AppTextSecondary"))
        } else {
          ProgressRingView(
            progress: Double(stars) / 3.0,
            lineWidth: 3,
            size: 48,
            showLabel: false
          )
          Text("\(level + 1)")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color("AppTextPrimary"))
        }
      }

      if !isLocked {
        StarRatingView(count: stars, size: 11)
        if isBest && stars > 0 {
          Text("Best")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color("AppBackground"))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color("AppPrimary"))
            .clipShape(Capsule())
        }
      } else {
        Text("Locked")
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(Color("AppTextSecondary"))
      }
    }
    .frame(maxWidth: .infinity)
    .frame(minHeight: 108)
    .padding(.vertical, 12)
    .padding(.horizontal, 8)
    .depthTile(cornerRadius: 16, glow: isBest && !isLocked)
    .opacity(isLocked ? 0.55 : 1)
  }
}

struct CustomDifficultyPicker: View {
    @Binding var selection: GameDifficulty
    let starsPerDifficulty: [GameDifficulty: Int]

  var body: some View {
    HStack(spacing: 8) {
      ForEach(GameDifficulty.allCases) { difficulty in
        let isSelected = selection == difficulty
        let stars = starsPerDifficulty[difficulty] ?? 0
        Button {
          HapticManager.lightTap()
          withAnimation(.easeInOut(duration: 0.3)) {
            selection = difficulty
          }
        } label: {
          VStack(spacing: 4) {
            Text(difficulty.displayName)
              .font(.caption.bold())
              .lineLimit(1)
              .minimumScaleFactor(0.7)
            HStack(spacing: 2) {
              Image(systemName: "star.fill")
                .font(.system(size: 8))
              Text("\(stars)")
                .font(.system(size: 10, weight: .semibold))
            }
          }
          .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background {
            if isSelected {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppGradients.primaryVertical)
            } else {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppGradients.surface)
            }
          }
          .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .strokeBorder(
                isSelected
                  ? AnyShapeStyle(Color("AppAccent").opacity(0.5))
                  : AnyShapeStyle(AppGradients.subtleBorder),
                lineWidth: 1
              )
          }
          .compositingGroup()
          .shadow(color: isSelected ? Color("AppPrimary").opacity(0.35) : Color.black.opacity(0.15), radius: isSelected ? 6 : 3, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
      }
    }
  }
}

// MARK: - Daily & Codex Cells

struct DailyChallengeCell: View {
    let challenge: DailyChallenge
    let isCompleted: Bool
    let streak: Int

  var body: some View {
    CustomCard(glow: !isCompleted) {
      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .top, spacing: 12) {
          ZStack {
            Circle()
              .fill(
                LinearGradient(
                  colors: [Color("AppPrimary").opacity(0.3), Color("AppAccent").opacity(0.15)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 52, height: 52)
            RuneSymbolView(symbol: .seal, size: 30, color: Color("AppPrimary"))
          }

          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
              Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
              Text("Daily Mystic Challenge")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            Text(challenge.title)
              .font(.caption.bold())
              .foregroundStyle(Color("AppPrimary"))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
            Text(challenge.flavorText)
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
              .lineLimit(2)
              .minimumScaleFactor(0.7)
          }
          Spacer(minLength: 0)
        }

        HStack(spacing: 12) {
          miniTag(icon: "flame.fill", text: "\(streak) day streak")
          if isCompleted {
            miniTag(icon: "checkmark.seal.fill", text: "Seal earned")
          }
        }

        if isCompleted {
          HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
              .foregroundStyle(Color("AppAccent"))
            Text("Return tomorrow for a new trial.")
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
          }
        } else {
          HStack {
            Text("Begin Trial")
              .font(.subheadline.bold())
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
              .font(.title3)
          }
          .foregroundStyle(Color("AppBackground"))
          .padding(.horizontal, 16)
          .padding(.vertical, 13)
          .primaryGradientFill(cornerRadius: 12)
          .compositingGroup()
          .shadow(color: Color("AppPrimary").opacity(0.35), radius: 6, y: 3)
        }
      }
      .padding(16)
    }
  }

  private func miniTag(icon: String, text: String) -> some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.system(size: 10))
      Text(text)
        .font(.system(size: 10, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .foregroundStyle(Color("AppAccent"))
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color("AppPrimary").opacity(0.12))
    .clipShape(Capsule())
  }
}

struct CodexRuneCellView: View {
    let rune: RuneDefinition
    let isDiscovered: Bool

  var body: some View {
    VStack(spacing: 10) {
      ZStack {
        Circle()
          .fill(
            isDiscovered
              ? LinearGradient(colors: [Color("AppPrimary").opacity(0.2), Color("AppAccent").opacity(0.1)], startPoint: .top, endPoint: .bottom)
              : LinearGradient(colors: [Color("AppSurface"), Color("AppBackground")], startPoint: .top, endPoint: .bottom)
          )
          .frame(width: 68, height: 68)
          .overlay {
            Circle()
              .stroke(rarityColor.opacity(isDiscovered ? 0.6 : 0.2), lineWidth: 1.5)
          }

        if isDiscovered {
          RuneSymbolView(symbol: rune.symbol, size: 36, color: Color("AppPrimary"))
        } else {
          Image(systemName: "questionmark")
            .font(.title3.bold())
            .foregroundStyle(Color("AppTextSecondary"))
        }
      }

      Text(isDiscovered ? rune.name : "???")
        .font(.caption.bold())
        .foregroundStyle(isDiscovered ? Color("AppTextPrimary") : Color("AppTextSecondary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Text(rune.rarity.rawValue)
        .font(.system(size: 9, weight: .bold))
        .foregroundStyle(isDiscovered ? rarityColor : Color("AppTextSecondary").opacity(0.5))
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(rarityColor.opacity(isDiscovered ? 0.15 : 0.05))
        .clipShape(Capsule())
    }
    .frame(maxWidth: .infinity, minHeight: 130)
    .padding(12)
    .depthTile(cornerRadius: 16, glow: isDiscovered)
    .opacity(isDiscovered ? 1 : 0.6)
  }

  private var rarityColor: Color {
    switch rune.rarity {
    case .common: return Color("AppTextPrimary")
    case .rare: return Color("AppAccent")
    case .ancient: return Color("AppPrimary")
    }
  }
}

// MARK: - Achievement Cell

struct AchievementCell: View {
    let achievement: Achievement
    let isAnimating: Bool
    let progressText: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        ZStack {
          Circle()
            .fill(achievement.isUnlocked ? Color("AppPrimary").opacity(0.2) : Color("AppBackground").opacity(0.4))
            .frame(width: 44, height: 44)
          Image(systemName: achievement.isUnlocked ? achievement.iconName : "lock.fill")
            .font(.body)
            .foregroundStyle(achievement.isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary"))
        }
        .scaleEffect(isAnimating ? 1.12 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isAnimating)

        Spacer()

        if achievement.isUnlocked {
          Image(systemName: "checkmark.seal.fill")
            .foregroundStyle(Color("AppAccent"))
        }
      }

      Text(achievement.title)
        .font(.subheadline.bold())
        .foregroundStyle(achievement.isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Text(achievement.description)
        .font(.caption)
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(2)
        .minimumScaleFactor(0.7)
        .fixedSize(horizontal: false, vertical: true)

      if !achievement.isUnlocked, let progressText {
        Text(progressText)
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(Color("AppAccent"))
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color("AppAccent").opacity(0.12))
          .clipShape(Capsule())
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
    .depthTile(cornerRadius: 16, glow: achievement.isUnlocked)
    .opacity(achievement.isUnlocked ? 1 : 0.75)
  }
}

// MARK: - Settings Cells

struct SettingsStatCell: View {
    let icon: String
    let label: String
    let value: String

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color("AppPrimary").opacity(0.12))
          .frame(width: 36, height: 36)
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundStyle(Color("AppPrimary"))
      }
      Text(label)
        .font(.subheadline)
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Spacer()
      Text(value)
        .font(.subheadline.bold())
        .foregroundStyle(Color("AppTextPrimary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 11)
  }
}

struct SettingsActionCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      HStack(spacing: 14) {
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(isDestructive ? Color.red.opacity(0.15) : Color("AppPrimary").opacity(0.12))
            .frame(width: 36, height: 36)
          Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(isDestructive ? Color.red : Color("AppPrimary"))
        }
        Text(title)
          .font(.body)
          .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Spacer()
        Image(systemName: "chevron.right")
          .font(.caption.bold())
          .foregroundStyle(Color("AppTextSecondary"))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
      .depthCard(cornerRadius: 14, elevation: .subtle)
    }
    .buttonStyle(ScaleButtonStyle())
  }
}

// MARK: - Path Map Cells

struct ChapterTabCell: View {
    let chapter: PathChapter
    let isSelected: Bool
    let progress: Double

  var body: some View {
    VStack(spacing: 6) {
      Text(chapter.rawValue)
        .font(.caption.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
      LinearProgressBar(progress: progress, height: 3)
        .opacity(isSelected ? 1 : 0.5)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background {
      if isSelected {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(AppGradients.primaryVertical)
      } else {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(AppGradients.surface)
      }
    }
    .overlay {
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .strokeBorder(
          isSelected
            ? AnyShapeStyle(Color("AppAccent").opacity(0.4))
            : AnyShapeStyle(AppGradients.subtleBorder),
          lineWidth: 1
        )
    }
    .compositingGroup()
    .shadow(color: isSelected ? Color("AppPrimary").opacity(0.3) : Color.black.opacity(0.18), radius: isSelected ? 5 : 3, y: 2)
  }
}

struct PathNodeListCell: View {
    let node: PathMapNode
    let isUnlocked: Bool
    let isCompleted: Bool

  var body: some View {
    HStack(spacing: 14) {
      ZStack {
        Circle()
          .fill(isCompleted ? Color("AppPrimary") : (isUnlocked ? Color("AppAccent").opacity(0.2) : Color("AppTextSecondary").opacity(0.15)))
          .frame(width: 44, height: 44)
        Image(systemName: isCompleted ? "checkmark" : (isUnlocked ? "play.fill" : "lock.fill"))
          .font(.caption.bold())
          .foregroundStyle(isCompleted ? Color("AppBackground") : (isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary")))
      }

      VStack(alignment: .leading, spacing: 3) {
        Text(node.title)
          .font(.subheadline.bold())
          .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Text(node.chapter.rawValue)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }

      Spacer()

      if isUnlocked && !isCompleted {
        Text("Play")
          .font(.caption.bold())
          .foregroundStyle(Color("AppBackground"))
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(AppGradients.primaryVertical)
          .clipShape(Capsule())
      }
    }
    .padding(12)
    .depthTile(cornerRadius: 14, glow: isCompleted)
    .opacity(isUnlocked ? 1 : 0.55)
  }
}

// MARK: - Achievement Progress Helper

enum AchievementProgress {
    static func hint(for achievement: Achievement, storage: AppStorage) -> String? {
        if achievement.isUnlocked { return nil }
        switch achievement.id {
        case "first_star":
            return "Earn 1 STAR to unlock"
        case "adventurer":
            return "\(storage.totalActivitiesPlayed)/10 activities"
        case "time_explorer":
            let mins = storage.totalPlayTimeSeconds / 60
            return "\(mins)/60 min played"
        case "puzzle_master":
            let done = ActivityInfo.all.filter { storage.starsForActivity(activityId: $0.id) >= 5 }.count
            return "\(done)/3 activities with 5+ stars"
        case "level_unlocker":
            return "\(storage.totalNewLevelsUnlocked)/3 levels unlocked"
        case "star_collector":
            return "\(storage.totalStarsEarned)/50 STARS"
        case "streak_seeker":
            return "\(storage.streakCount)/7 day streak"
        case "codex_scholar":
            return "\(storage.discoveredRuneCount)/10 runes"
        case "daily_guardian":
            return "\(storage.dailyChallengeStreak)/7 daily streak"
        case "path_weaver":
            return "\(storage.completedPathNodeCount)/5 nodes cleared"
        default:
            return nil
        }
    }
}
