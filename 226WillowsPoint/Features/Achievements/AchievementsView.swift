import SwiftUI

enum AchievementFilter: String, CaseIterable {
    case all = "All"
    case unlocked = "Unlocked"
    case locked = "Locked"
}

struct AchievementsView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var animateUnlocks: Set<String> = []
    @State private var filter: AchievementFilter = .all

    private var allAchievements: [Achievement] {
        Achievement.all(from: storage)
    }

    private var filteredAchievements: [Achievement] {
        switch filter {
        case .all: return allAchievements
        case .unlocked: return allAchievements.filter(\.isUnlocked)
        case .locked: return allAchievements.filter { !$0.isUnlocked }
        }
    }

    private var unlockedCount: Int {
        allAchievements.filter(\.isUnlocked).count
    }

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            ScreenHeaderView(
              title: "Achievements",
              subtitle: "Unlock badges by completing challenges across your adventure.",
              badge: "\(unlockedCount)/\(allAchievements.count)"
            )

            HStack(spacing: 8) {
              ProgressRingView(
                progress: allAchievements.isEmpty ? 0 : Double(unlockedCount) / Double(allAchievements.count),
                size: 56
              )
              VStack(alignment: .leading, spacing: 6) {
                Text("Collection Progress")
                  .font(.caption.bold())
                  .foregroundStyle(Color("AppTextSecondary"))
                LinearProgressBar(
                  progress: allAchievements.isEmpty ? 0 : Double(unlockedCount) / Double(allAchievements.count)
                )
                Text("\(unlockedCount) of \(allAchievements.count) badges earned")
                  .font(.caption)
                  .foregroundStyle(Color("AppTextPrimary"))
              }
            }
            .padding(14)
            .depthCard(cornerRadius: 16, elevation: .raised)
            .depthTopSheen(cornerRadius: 16)

            filterPicker

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
              ForEach(filteredAchievements) { achievement in
                AchievementCell(
                  achievement: achievement,
                  isAnimating: animateUnlocks.contains(achievement.id),
                  progressText: AchievementProgress.hint(for: achievement, storage: storage)
                )
                .onAppear {
                  if achievement.isUnlocked && !storage.previouslyUnlockedAchievements.contains(achievement.id) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                      animateUnlocks.insert(achievement.id)
                    }
                    HapticManager.success()
                  }
                }
              }
            }

            if filteredAchievements.isEmpty {
              Text("No badges in this category yet.")
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
          }
          .padding(16)
          .padding(.bottom, 100)
        }
      }
    }
  }

  private var filterPicker: some View {
    HStack(spacing: 8) {
      ForEach(AchievementFilter.allCases, id: \.rawValue) { item in
        Button {
          HapticManager.lightTap()
          withAnimation(.easeInOut(duration: 0.3)) {
            filter = item
          }
        } label: {
            Text(item.rawValue)
              .font(.caption.bold())
              .foregroundStyle(filter == item ? Color("AppBackground") : Color("AppTextSecondary"))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 10)
              .background {
                if filter == item {
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppGradients.primaryVertical)
                } else {
                  RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppGradients.surface)
                }
              }
              .compositingGroup()
              .shadow(color: filter == item ? Color("AppPrimary").opacity(0.28) : Color.clear, radius: 4, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
      }
    }
  }
}
