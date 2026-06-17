import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var storage: AppStorage

  var body: some View {
    NavigationStack {
      ZStack {
        PlayAnimatedBackground()

        ScrollView {
          VStack(alignment: .leading, spacing: 22) {
            ScreenHeaderView(
              title: "Your Adventure Awaits",
              subtitle: motivationalSubtitle,
              badge: storage.totalStarsEarned > 0 ? "\(storage.totalStarsEarned) ⭐" : nil
            )

            HStack(spacing: 8) {
              StatPillCell(icon: "star.fill", value: "\(storage.totalStarsEarned)", label: "STARS", accent: true)
              StatPillCell(icon: "book.fill", value: "\(storage.discoveredRuneCount)", label: "Runes")
              StatPillCell(icon: "flame.fill", value: "\(storage.dailyChallengeStreak)", label: "Streak")
            }

            NavigationLink(value: storage.todayDailyChallenge.route) {
              DailyChallengeCell(
                challenge: storage.todayDailyChallenge,
                isCompleted: storage.isTodayDailyChallengeCompleted,
                streak: storage.dailyChallengeStreak
              )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
              if !storage.isTodayDailyChallengeCompleted {
                HapticManager.mediumTap()
              }
            })
            .disabled(storage.isTodayDailyChallengeCompleted)

            SectionHeaderView(
              title: "Activities",
              trailing: "\(ActivityInfo.all.count) available"
            )

            ForEach(ActivityInfo.all) { activity in
              NavigationLink(value: activity) {
                ActivityCardCell(
                  activity: activity,
                  stars: storage.starsForActivity(activityId: activity.id),
                  levelsCompleted: storage.completedLevelsCount(activityId: activity.id),
                  totalLevels: 15
                )
              }
              .buttonStyle(.plain)
              .simultaneousGesture(TapGesture().onEnded {
                HapticManager.lightTap()
              })
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .padding(.bottom, 100)
        }
      }
      .navigationDestination(for: ActivityInfo.self) { activity in
        LevelSelectionView(activity: activity)
      }
      .navigationDestination(for: LevelRoute.self) { route in
        GameViewFactory.view(for: route)
      }
    }
  }

  private var motivationalSubtitle: String {
    let totalStars = storage.totalStarsEarned
    if totalStars == 0 {
      return "Tap an activity below to begin your mystical journey."
    } else if totalStars < 10 {
      return "Keep exploring — \(totalStars) STARS collected so far!"
    } else {
      return "You're becoming a legend — \(totalStars) STARS shine in your path!"
    }
  }
}

struct PlayAnimatedBackground: View {
    @State private var phase: CGFloat = 0

  var body: some View {
    ZStack {
      BackgroundPatternView()
      Canvas { context, size in
        for i in 0..<8 {
          let x = size.width * CGFloat(i + 1) / 9 + sin(phase + CGFloat(i)) * 24
          let y = size.height * 0.28 + cos(phase + CGFloat(i) * 0.6) * 36
          let rect = CGRect(x: x - 6, y: y - 6, width: 12, height: 12)
          context.fill(
            Path(ellipseIn: rect),
            with: .color(Color("AppAccent").opacity(0.12))
          )
        }
      }
      .ignoresSafeArea()
    }
    .onAppear {
      withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
        phase = .pi * 2
      }
    }
  }
}
