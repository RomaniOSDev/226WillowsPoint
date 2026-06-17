import SwiftUI

struct OnboardingPageData {
    let stepLabel: String
    let headline: String
    let body: String
    let iconName: String
    let highlights: [(icon: String, text: String)]
    let glow: Bool
}

struct OnboardingView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var currentPage = 0

    private let pages: [OnboardingPageData] = [
        OnboardingPageData(
            stepLabel: "Step 1",
            headline: "Tap the Runes",
            body: "Discover hidden runes scattered across mystical stones. Tap them in the right order to unlock ancient pathways.",
            iconName: "hand.tap.fill",
            highlights: [
                ("sparkles", "Hidden runes"),
                ("hand.tap", "Tap to activate"),
                ("arrow.triangle.branch", "Connect paths")
            ],
            glow: false
        ),
        OnboardingPageData(
            stepLabel: "Step 2",
            headline: "Earn Your Stars",
            body: "Solve puzzles across three unique activities. Faster completions and perfect runs earn more STARS for your collection.",
            iconName: "star.fill",
            highlights: [
                ("star.fill", "Earn STARS"),
                ("chart.line.uptrend.xyaxis", "Track progress"),
                ("trophy.fill", "Unlock badges")
            ],
            glow: false
        ),
        OnboardingPageData(
            stepLabel: "Step 3",
            headline: "Begin Your Journey",
            body: "Explore the path map, grow your rune codex, and take on a new daily challenge every day. Your adventure starts now.",
            iconName: "map.fill",
            highlights: [
                ("map.fill", "Path Weaver"),
                ("book.fill", "Rune Codex"),
                ("flame.fill", "Daily trials")
            ],
            glow: true
        )
    ]

  var body: some View {
    ZStack {
      BackgroundPatternView()

      VStack(spacing: 0) {
        onboardingHeader

        TabView(selection: $currentPage) {
          ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
            OnboardingPageView(page: page, pageIndex: index)
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentPage)

        bottomPanel
      }
    }
  }

  private var onboardingHeader: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 6) {
          Text("Welcome, Traveler")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)

          Text("Learn the basics in 3 quick steps")
            .font(.subheadline)
            .foregroundStyle(Color("AppTextSecondary"))
        }
        Spacer(minLength: 8)
        GradientBadge(text: "\(currentPage + 1)/\(pages.count)")
      }

      Capsule()
        .fill(AppGradients.primary)
        .frame(height: 3)
        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 4, y: 1)
    }
    .padding(.horizontal, 24)
    .padding(.top, 20)
    .padding(.bottom, 8)
    .animation(.easeInOut(duration: 0.3), value: currentPage)
  }

  private var bottomPanel: some View {
    VStack(spacing: 16) {
      pageIndicatorRow

      HStack(spacing: 12) {
        if currentPage < pages.count - 1 {
          Button {
            HapticManager.lightTap()
            storage.hasSeenOnboarding = true
          } label: {
            Text("Skip")
              .font(.subheadline.bold())
              .foregroundStyle(Color("AppTextSecondary"))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(AppGradients.surface)
              .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
              .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                  .strokeBorder(AppGradients.subtleBorder, lineWidth: 1)
              }
          }
          .buttonStyle(ScaleButtonStyle())
        }

        PrimaryButton(title: currentPage == pages.count - 1 ? "Get Started" : "Next") {
          if currentPage < pages.count - 1 {
            HapticManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
              currentPage += 1
            }
          } else {
            HapticManager.mediumTap()
            storage.hasSeenOnboarding = true
          }
        }
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 18)
    .background {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(AppGradients.surfaceHighlight)
        .overlay {
          RoundedRectangle(cornerRadius: 28, style: .continuous)
            .strokeBorder(AppGradients.subtleBorder, lineWidth: 1)
        }
    }
    .depthTopSheen(cornerRadius: 28)
    .compositingGroup()
    .shadow(color: Color.black.opacity(0.4), radius: 16, y: -2)
    .padding(.horizontal, 16)
    .padding(.bottom, 24)
  }

  private var pageIndicatorRow: some View {
    HStack(spacing: 8) {
      ForEach(0..<pages.count, id: \.self) { index in
        Capsule()
          .fill(
            index == currentPage
              ? AnyShapeStyle(AppGradients.primary)
              : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25))
          )
          .frame(width: index == currentPage ? 28 : 8, height: 8)
          .shadow(color: index == currentPage ? Color("AppPrimary").opacity(0.4) : Color.clear, radius: 4, y: 1)
          .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct OnboardingPageView: View {
    let page: OnboardingPageData
    let pageIndex: Int

    @State private var appeared = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 20) {
        illustrationCard
          .scaleEffect(appeared ? 1.0 : 0.92)
          .opacity(appeared ? 1.0 : 0.0)
          .animation(.spring(response: 0.45, dampingFraction: 0.75), value: appeared)

        CustomCard(glow: page.glow, elevation: .raised) {
          VStack(spacing: 16) {
            HStack(spacing: 10) {
              ZStack {
                Circle()
                  .fill(
                    LinearGradient(
                      colors: [Color("AppPrimary").opacity(0.25), Color("AppAccent").opacity(0.12)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 44, height: 44)
                Image(systemName: page.iconName)
                  .font(.body.bold())
                  .foregroundStyle(Color("AppPrimary"))
              }

              VStack(alignment: .leading, spacing: 2) {
                Text(page.stepLabel)
                  .font(.caption.bold())
                  .foregroundStyle(Color("AppAccent"))
                Text(page.headline)
                  .font(.title3.bold())
                  .foregroundStyle(Color("AppTextPrimary"))
                  .lineLimit(2)
                  .minimumScaleFactor(0.8)
              }
              Spacer(minLength: 0)
            }

            Text(page.body)
              .font(.body)
              .foregroundStyle(Color("AppTextSecondary"))
              .multilineTextAlignment(.leading)
              .fixedSize(horizontal: false, vertical: true)

            highlightChips
          }
          .padding(20)
        }
        .offset(y: appeared ? 0 : 16)
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.08), value: appeared)
      }
      .padding(.horizontal, 24)
      .padding(.top, 8)
      .padding(.bottom, 16)
    }
    .onAppear { appeared = true }
    .onDisappear { appeared = false }
  }

  private var illustrationCard: some View {
    ZStack(alignment: .bottomLeading) {
      illustrationContent
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipped()

      LinearGradient(
        colors: [Color.clear, Color("AppBackground").opacity(0.5), Color("AppBackground").opacity(0.85)],
        startPoint: .center,
        endPoint: .bottom
      )

      HStack(spacing: 8) {
        Image(systemName: page.iconName)
          .font(.caption.bold())
          .foregroundStyle(Color("AppPrimary"))
        Text(page.stepLabel)
          .font(.caption.bold())
          .foregroundStyle(Color("AppTextPrimary"))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color("AppBackground").opacity(0.65))
      .clipShape(Capsule())
      .padding(14)
    }
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .strokeBorder(
          page.glow ? AppGradients.accentBorder : AppGradients.subtleBorder,
          lineWidth: page.glow ? 1.5 : 1
        )
    }
    .compositingGroup()
    .shadow(color: Color.black.opacity(page.glow ? 0.45 : 0.32), radius: page.glow ? 14 : 10, y: 6)
    .depthTopSheen(cornerRadius: 22)
  }

  @ViewBuilder
  private var illustrationContent: some View {
    switch pageIndex {
    case 0:
      ZStack {
        Image("ActivityTrail")
          .resizable()
          .scaledToFill()
        OnboardingRuneOverlay()
      }
    case 1:
      OnboardingStarsIllustration()
    default:
      ZStack {
        Image("HomeHero")
          .resizable()
          .scaledToFill()
        OnboardingPathOverlay()
      }
    }
  }

  private var highlightChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(page.highlights, id: \.text) { item in
          HStack(spacing: 4) {
            Image(systemName: item.icon)
              .font(.system(size: 9, weight: .semibold))
            Text(item.text)
              .font(.system(size: 10, weight: .semibold))
              .lineLimit(1)
          }
          .foregroundStyle(Color("AppAccent"))
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Color("AppPrimary").opacity(0.12))
          .clipShape(Capsule())
        }
      }
    }
  }
}

// MARK: - Illustrations (static SwiftUI, no animated Canvas)

struct OnboardingRuneOverlay: View {
  var body: some View {
    GeometryReader { geo in
      let positions: [(x: CGFloat, y: CGFloat)] = [
        (0.18, 0.28), (0.82, 0.22), (0.12, 0.72), (0.88, 0.78)
      ]
      ForEach(0..<positions.count, id: \.self) { index in
        let pos = positions[index]
        Circle()
          .fill(
            LinearGradient(
              colors: [Color("AppPrimary").opacity(0.85), Color("AppAccent").opacity(0.6)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 36, height: 36)
          .overlay {
            Circle()
              .strokeBorder(Color("AppAccent").opacity(0.7), lineWidth: 1.5)
          }
          .position(x: pos.x * geo.size.width, y: pos.y * geo.size.height)
      }
    }
  }
}

struct OnboardingStarsIllustration: View {
  var body: some View {
    ZStack {
      AppGradients.surface

      RadialGradient(
        colors: [Color("AppPrimary").opacity(0.15), Color.clear],
        center: .center,
        startRadius: 20,
        endRadius: 160
      )

      ForEach(0..<3, id: \.self) { index in
        let angle = Double(index) * 2.0 * .pi / 3.0 - .pi / 2
        let radius: CGFloat = 64
        Image(systemName: "star.fill")
          .font(.system(size: index == 0 ? 52 : 40))
          .foregroundStyle(
            LinearGradient(
              colors: [Color("AppPrimary"), Color("AppAccent")],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .overlay {
            Image(systemName: "star")
              .font(.system(size: index == 0 ? 52 : 40))
              .foregroundStyle(Color("AppAccent").opacity(0.35))
          }
          .offset(
            x: CGFloat(cos(angle)) * radius,
            y: CGFloat(sin(angle)) * radius
          )
      }

      Text("STARS")
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .foregroundStyle(Color("AppAccent"))
        .offset(y: 90)
    }
  }
}

struct OnboardingPathOverlay: View {
  var body: some View {
    GeometryReader { geo in
      Path { path in
        path.move(to: CGPoint(x: geo.size.width * 0.08, y: geo.size.height * 0.75))
        path.addCurve(
          to: CGPoint(x: geo.size.width * 0.92, y: geo.size.height * 0.25),
          control1: CGPoint(x: geo.size.width * 0.35, y: geo.size.height * 0.15),
          control2: CGPoint(x: geo.size.width * 0.65, y: geo.size.height * 0.85)
        )
      }
      .stroke(
        AppGradients.primary,
        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6])
      )

      ForEach([0.2, 0.5, 0.82], id: \.self) { t in
        let point = bezierPoint(t: t, in: geo.size)
        Circle()
          .fill(AppGradients.primaryVertical)
          .frame(width: 22, height: 22)
          .overlay {
            Circle()
              .strokeBorder(Color("AppAccent").opacity(0.5), lineWidth: 1)
          }
          .position(point)
      }
    }
  }

  private func bezierPoint(t: CGFloat, in size: CGSize) -> CGPoint {
    let start = CGPoint(x: size.width * 0.08, y: size.height * 0.75)
    let end = CGPoint(x: size.width * 0.92, y: size.height * 0.25)
    let c1 = CGPoint(x: size.width * 0.35, y: size.height * 0.15)
    let c2 = CGPoint(x: size.width * 0.65, y: size.height * 0.85)
    let u = 1 - t
    let x = u * u * u * start.x + 3 * u * u * t * c1.x + 3 * u * t * t * c2.x + t * t * t * end.x
    let y = u * u * u * start.y + 3 * u * u * t * c1.y + 3 * u * t * t * c2.y + t * t * t * end.y
    return CGPoint(x: x, y: y)
  }
}
