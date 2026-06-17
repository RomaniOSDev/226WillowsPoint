import SwiftUI

// MARK: - Shared Gradients (static, no re-computation per frame)

enum AppGradients {
    static var background: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface").opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppBackground").opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceHighlight: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.95),
                Color("AppSurface")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primary: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var primaryVertical: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var accentBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.7),
                Color("AppAccent").opacity(0.35),
                Color("AppPrimary").opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.12),
                Color("AppTextSecondary").opacity(0.06),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var progress: LinearGradient {
        primary
    }

    static var ring: AngularGradient {
        AngularGradient(
            colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
            center: .center
        )
    }
}

// MARK: - Elevation (single shadow via compositingGroup)

enum DepthElevation {
    case subtle
    case raised
    case floating

    var radius: CGFloat {
        switch self {
        case .subtle: return 4
        case .raised: return 8
        case .floating: return 14
        }
    }

    var y: CGFloat {
        switch self {
        case .subtle: return 2
        case .raised: return 4
        case .floating: return 7
        }
    }

    var opacity: Double {
        switch self {
        case .subtle: return 0.22
        case .raised: return 0.32
        case .floating: return 0.42
        }
    }
}

extension View {
    /// Optimized card depth: 1 gradient fill + 1 border + 1 composited shadow.
    func depthCard(
        cornerRadius: CGFloat = 18,
        elevation: DepthElevation = .raised,
        glow: Bool = false
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    glow ? AppGradients.accentBorder : AppGradients.subtleBorder,
                    lineWidth: glow ? 1.5 : 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compositingGroup()
        .shadow(
            color: Color.black.opacity(elevation.opacity),
            radius: elevation.radius,
            x: 0,
            y: elevation.y
        )
    }

    /// Lighter depth for grid cells inside LazyVGrid (cheaper shadow).
    func depthTile(cornerRadius: CGFloat = 16, glow: Bool = false) -> some View {
        depthCard(cornerRadius: cornerRadius, elevation: .subtle, glow: glow)
    }

    /// Top highlight line for volume illusion (no shadow cost).
    func depthTopSheen(cornerRadius: CGFloat = 18) -> some View {
        overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppTextPrimary").opacity(0.07), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(height: 28)
                .allowsHitTesting(false)
        }
    }

    func primaryGradientFill(cornerRadius: CGFloat = 14) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.primary)
        )
    }
}

// MARK: - Reusable depth shapes

struct DepthSurface: View {
    var cornerRadius: CGFloat = 18

  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      .fill(AppGradients.surface)
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(AppGradients.subtleBorder, lineWidth: 1)
      }
  }
}

struct GradientBadge: View {
    let text: String

  var body: some View {
    Text(text)
      .font(.caption2.bold())
      .foregroundStyle(Color("AppBackground"))
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(AppGradients.primary)
      .clipShape(Capsule())
      .compositingGroup()
      .shadow(color: Color("AppPrimary").opacity(0.35), radius: 4, y: 2)
  }
}
