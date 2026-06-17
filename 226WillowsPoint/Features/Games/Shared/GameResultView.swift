import SwiftUI

struct GameResultView: View {
    let isSuccess: Bool
    let stars: Int
    let primaryMetric: String
    let metricLabel: String
    let showNextLevel: Bool
    let newlyUnlockedAchievement: Achievement?
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var showFailFlash = false
    @State private var showAchievementBanner = false

  var body: some View {
    ZStack {
      BackgroundPatternView()

      ScrollView {
        VStack(spacing: 24) {
          Spacer(minLength: 40)

          resultHeader

          if isSuccess {
            StarRatingView(count: stars, animated: true)
              .padding(.vertical, 8)

            CustomCard(glow: true) {
              VStack(spacing: 8) {
                Text(primaryMetric)
                  .font(.system(size: 52, weight: .bold, design: .rounded))
                  .foregroundStyle(Color("AppPrimary"))
                Text(metricLabel)
                  .font(.subheadline)
                  .foregroundStyle(Color("AppTextSecondary"))
              }
              .frame(maxWidth: .infinity)
              .padding(.vertical, 20)
            }
          } else {
            StarRatingView(count: 0)
              .padding(.vertical, 8)

            CustomCard {
              VStack(spacing: 10) {
                Image(systemName: "wind")
                  .font(.largeTitle)
                  .foregroundStyle(Color("AppTextSecondary"))
                Text("The mystical pathways faded away.")
                  .font(.body)
                  .foregroundStyle(Color("AppTextSecondary"))
                  .multilineTextAlignment(.center)
              }
              .padding(20)
            }
          }

          VStack(spacing: 12) {
            if isSuccess && showNextLevel {
              PrimaryButton(title: "Next Level") {
                HapticManager.mediumTap()
                onNextLevel()
              }
            }

            PrimaryButton(title: "Retry") {
              HapticManager.mediumTap()
              onRetry()
            }

            PrimaryButton(title: "Back to Levels") {
              HapticManager.lightTap()
              onBackToLevels()
            }
          }
          .padding(.top, 8)

          Spacer(minLength: 40)
        }
        .padding(.horizontal, 20)
      }

      if let achievement = newlyUnlockedAchievement, showAchievementBanner {
        VStack {
          CustomCard(glow: true) {
            HStack(spacing: 12) {
              ZStack {
                Circle()
                  .fill(Color("AppPrimary").opacity(0.2))
                  .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                  .foregroundStyle(Color("AppPrimary"))
              }
              VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                  .font(.caption.bold())
                  .foregroundStyle(Color("AppAccent"))
                Text(achievement.title)
                  .font(.subheadline.bold())
                  .foregroundStyle(Color("AppTextPrimary"))
              }
              Spacer()
            }
            .padding(14)
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
      }

      FailFlashOverlay(isVisible: $showFailFlash)
    }
    .onAppear {
      if isSuccess {
        HapticManager.success()
        SoundManager.playSuccess()
        if newlyUnlockedAchievement != nil {
          withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
            showAchievementBanner = true
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
              showAchievementBanner = false
            }
          }
        }
      } else {
        showFailFlash = true
        HapticManager.error()
        SoundManager.playFail()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          showFailFlash = false
        }
      }
    }
  }

  private var resultHeader: some View {
    VStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(
            isSuccess
              ? LinearGradient(
                  colors: [Color("AppPrimary").opacity(0.3), Color("AppAccent").opacity(0.12)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              : LinearGradient(
                  colors: [Color.red.opacity(0.2), Color.red.opacity(0.08)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
          )
          .frame(width: 80, height: 80)
          .overlay {
            Circle()
              .strokeBorder(
                isSuccess ? AppGradients.accentBorder : LinearGradient(
                  colors: [Color.red.opacity(0.4), Color.red.opacity(0.15)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
              )
          }
        Image(systemName: isSuccess ? "sparkles" : "xmark.circle")
          .font(.largeTitle)
          .foregroundStyle(isSuccess ? Color("AppPrimary") : Color.red.opacity(0.8))
      }
      .compositingGroup()
      .shadow(color: (isSuccess ? Color("AppPrimary") : Color.red).opacity(0.35), radius: 10, y: 4)

      Text(isSuccess ? "Level Complete!" : "Try Again")
        .font(.largeTitle.bold())
        .foregroundStyle(Color("AppTextPrimary"))
        .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
    }
  }
}
