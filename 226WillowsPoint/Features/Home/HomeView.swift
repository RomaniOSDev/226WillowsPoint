import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorage
    @EnvironmentObject private var tabRouter: TabRouter

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          VStack(spacing: 20) {
            heroBanner
            statsWidgetGrid
            dailyWidget
            activitiesSection
            bottomWidgetsRow
            continueWidget
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

  // MARK: - Hero

  private var heroBanner: some View {
    ZStack(alignment: .bottomLeading) {
      Image("HomeHero")
        .resizable()
        .scaledToFill()
        .frame(height: 200)
        .clipped()

      LinearGradient(
        colors: [Color.clear, Color("AppBackground").opacity(0.85), Color("AppBackground")],
        startPoint: .top,
        endPoint: .bottom
      )

      VStack(alignment: .leading, spacing: 6) {
        Text(greeting)
          .font(.caption.bold())
          .foregroundStyle(Color("AppAccent"))
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(Color("AppBackground").opacity(0.6))
          .clipShape(Capsule())

        Text(heroTitle)
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(2)
          .minimumScaleFactor(0.8)

        Text(heroSubtitle)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)
      }
      .padding(16)
    }
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .strokeBorder(AppGradients.accentBorder, lineWidth: 1.5)
    }
    .compositingGroup()
    .shadow(color: Color.black.opacity(0.45), radius: 14, y: 7)
    .depthTopSheen(cornerRadius: 22)
  }

  // MARK: - Stats Grid

  private var statsWidgetGrid: some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
      HomeStatWidget(
        icon: "star.fill",
        value: "\(storage.totalStarsEarned)",
        label: "Total STARS",
        accent: true
      )
      HomeStatWidget(
        icon: "book.closed.fill",
        value: "\(storage.discoveredRuneCount)/\(RuneDefinition.catalog.count)",
        label: "Runes Found"
      )
      HomeStatWidget(
        icon: "map.fill",
        value: "\(storage.completedPathNodeCount)/\(PathMapNode.allNodes.count)",
        label: "Path Progress"
      )
      HomeStatWidget(
        icon: "flame.fill",
        value: "\(storage.dailyChallengeStreak)",
        label: "Daily Streak"
      )
    }
  }

  // MARK: - Daily Widget

  private var dailyWidget: some View {
    Group {
      if storage.isTodayDailyChallengeCompleted {
        completedDailyWidget
      } else {
        NavigationLink(value: storage.todayDailyChallenge.route) {
          activeDailyWidget
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
          HapticManager.mediumTap()
        })
      }
    }
  }

  private var activeDailyWidget: some View {
    HStack(spacing: 0) {
      Image("WidgetDaily")
        .resizable()
        .scaledToFill()
        .frame(width: 110)
        .clipped()

      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 6) {
          Image(systemName: "sparkles")
            .foregroundStyle(Color("AppAccent"))
          Text("Daily Trial")
            .font(.caption.bold())
            .foregroundStyle(Color("AppAccent"))
        }

        Text(storage.todayDailyChallenge.title)
          .font(.headline)
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)

        Text(storage.todayDailyChallenge.flavorText)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .lineLimit(2)
          .minimumScaleFactor(0.7)

        HStack {
          Text("Play Now")
            .font(.caption.bold())
          Image(systemName: "arrow.right")
            .font(.caption.bold())
        }
        .foregroundStyle(Color("AppBackground"))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .primaryGradientFill(cornerRadius: 20)
      }
      .padding(14)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .depthCard(cornerRadius: 18, elevation: .raised, glow: true)
    .depthTopSheen(cornerRadius: 18)
  }

  private var completedDailyWidget: some View {
    HStack(spacing: 14) {
      Image("WidgetDaily")
        .resizable()
        .scaledToFill()
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 6) {
          Image(systemName: "checkmark.seal.fill")
            .foregroundStyle(Color("AppPrimary"))
          Text("Daily Trial Complete")
            .font(.subheadline.bold())
            .foregroundStyle(Color("AppTextPrimary"))
        }
        Text("Seal earned! New trial tomorrow.")
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
      }
      Spacer()
    }
    .padding(14)
    .depthCard(cornerRadius: 18, elevation: .subtle)
  }

  // MARK: - Activities

  private var activitiesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionHeaderView(title: "Quick Play", trailing: "3 activities")

      ForEach(ActivityInfo.all) { activity in
        NavigationLink(value: activity) {
          HomeActivityWidget(
            activity: activity,
            stars: storage.starsForActivity(activityId: activity.id),
            progress: Double(storage.completedLevelsCount(activityId: activity.id)) / 15.0
          )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
          HapticManager.lightTap()
        })
      }
    }
  }

  // MARK: - Bottom Widgets

  private var bottomWidgetsRow: some View {
    HStack(spacing: 12) {
      Button {
        HapticManager.lightTap()
        withAnimation(.easeInOut(duration: 0.3)) {
          tabRouter.switchTo(.map)
        }
      } label: {
        HomeMiniWidget(
          imageName: "HomeHero",
          title: "Path Map",
          value: "\(Int(pathProgress * 100))%",
          subtitle: "Forest journey"
        )
      }
      .buttonStyle(ScaleButtonStyle())

      Button {
        HapticManager.lightTap()
        withAnimation(.easeInOut(duration: 0.3)) {
          tabRouter.switchTo(.codex)
        }
      } label: {
        HomeMiniWidget(
          imageName: "WidgetDaily",
          title: "Rune Codex",
          value: "\(storage.discoveredRuneCount)",
          subtitle: "Discovered"
        )
      }
      .buttonStyle(ScaleButtonStyle())
    }
  }

  private var continueWidget: some View {
    CustomCard(glow: suggestedActivity != nil) {
      HStack(spacing: 14) {
        if let activity = suggestedActivity {
          Image(activity.imageAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))

          VStack(alignment: .leading, spacing: 4) {
            Text("Continue Adventure")
              .font(.caption.bold())
              .foregroundStyle(Color("AppAccent"))
            Text(activity.title)
              .font(.headline)
              .foregroundStyle(Color("AppTextPrimary"))
              .lineLimit(1)
              .minimumScaleFactor(0.7)
            Text("Pick up where you left off")
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
          }

          Spacer()

          NavigationLink(value: activity) {
            Image(systemName: "play.circle.fill")
              .font(.system(size: 36))
              .foregroundStyle(Color("AppPrimary"))
          }
          .buttonStyle(.plain)
        } else {
          VStack(alignment: .leading, spacing: 6) {
            Text("Start Your Journey")
              .font(.headline)
              .foregroundStyle(Color("AppTextPrimary"))
            Text("Choose an activity above to begin earning STARS.")
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
          }
          Spacer()
        }
      }
      .padding(14)
    }
  }

  // MARK: - Helpers

  private var greeting: String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 12 { return "Good Morning, Explorer" }
    if hour < 17 { return "Good Afternoon, Explorer" }
    return "Good Evening, Explorer"
  }

  private var heroTitle: String {
    if storage.totalStarsEarned == 0 {
      return "The Forest Awaits"
    }
    return "Keep Weaving Your Path"
  }

  private var heroSubtitle: String {
    if storage.totalActivitiesPlayed == 0 {
      return "Tap an activity below and discover hidden runes."
    }
    return "\(storage.totalStarsEarned) STARS earned · \(storage.totalActivitiesPlayed) trials completed"
  }

  private var pathProgress: Double {
    guard !PathMapNode.allNodes.isEmpty else { return 0 }
    return Double(storage.completedPathNodeCount) / Double(PathMapNode.allNodes.count)
  }

  private var suggestedActivity: ActivityInfo? {
    ActivityInfo.all.max(by: { a, b in
      storage.starsForActivity(activityId: a.id) < storage.starsForActivity(activityId: b.id)
    })
  }
}

// MARK: - Widget Components

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    var accent: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Image(systemName: icon)
          .font(.body)
          .foregroundStyle(accent ? Color("AppPrimary") : Color("AppTextSecondary"))
        Spacer()
        if accent {
          Circle()
            .fill(Color("AppPrimary").opacity(0.3))
            .frame(width: 8, height: 8)
        }
      }
      Text(value)
        .font(.system(size: 22, weight: .bold, design: .rounded))
        .foregroundStyle(Color("AppTextPrimary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(Color("AppTextSecondary"))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .padding(14)
    .depthTile(cornerRadius: 16, glow: accent)
  }
}

struct HomeActivityWidget: View {
    let activity: ActivityInfo
    let stars: Int
    let progress: Double

  var body: some View {
    HStack(spacing: 0) {
      Image(activity.imageAssetName)
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipped()

      VStack(alignment: .leading, spacing: 8) {
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
          Label("\(stars)", systemImage: "star.fill")
            .font(.caption.bold())
            .foregroundStyle(Color("AppPrimary"))
          Text("·")
            .foregroundStyle(Color("AppTextSecondary"))
          Text("\(Int(progress * 100))% done")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
        }

        LinearProgressBar(progress: progress, height: 4)
      }
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)

      Image(systemName: "chevron.right")
        .font(.caption.bold())
        .foregroundStyle(Color("AppPrimary"))
        .padding(.trailing, 14)
    }
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    .depthCard(cornerRadius: 18, elevation: .raised)
    .depthTopSheen(cornerRadius: 18)
  }
}

struct HomeMiniWidget: View {
    let imageName: String
    let title: String
    let value: String
    let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Image(imageName)
        .resizable()
        .scaledToFill()
        .frame(height: 72)
        .clipped()

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.caption.bold())
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Text(value)
          .font(.title3.bold())
          .foregroundStyle(Color("AppPrimary"))
        Text(subtitle)
          .font(.system(size: 9))
          .foregroundStyle(Color("AppTextSecondary"))
      }
      .padding(10)
    }
    .frame(maxWidth: .infinity)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .depthTile(cornerRadius: 16)
  }
}
