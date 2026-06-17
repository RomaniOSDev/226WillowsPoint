import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void

  var body: some View {
    Button {
      HapticManager.lightTap()
      action()
    } label: {
      Text(title)
        .font(.headline)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .foregroundStyle(isDestructive ? Color("AppTextPrimary") : Color("AppBackground"))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
          if isDestructive {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .fill(Color.red.opacity(0.85))
          } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .fill(AppGradients.primaryVertical)
          }
        }
        .overlay {
          RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(Color("AppTextPrimary").opacity(isDestructive ? 0 : 0.15), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .compositingGroup()
        .shadow(color: isDestructive ? Color.clear : Color("AppPrimary").opacity(0.35), radius: 8, y: 4)
    }
    .buttonStyle(ScaleButtonStyle())
  }
}

struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
  }
}

struct StarRatingView: View {
    let count: Int
    var maxStars: Int = 3
    var size: CGFloat = 20
    var animated: Bool = false
    @State private var visibleStars = 0

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<maxStars, id: \.self) { index in
        let filled = index < (animated ? visibleStars : count)
        Image(systemName: filled ? "star.fill" : "star")
          .font(.system(size: size))
          .foregroundStyle(filled ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
          .scaleEffect(filled ? 1.0 : 0.85)
      }
    }
    .onAppear {
      guard animated else { return }
      visibleStars = 0
      for i in 1...count {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
          withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            visibleStars = i
          }
          HapticManager.success()
        }
      }
    }
  }
}

struct GameTopHUD: View {
    let leading: String
    let trailing: String
    var subtitle: String?

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Text(leading)
          .font(.headline)
          .foregroundStyle(Color("AppTextPrimary"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Spacer(minLength: 8)
        Text(trailing)
          .font(.headline)
          .foregroundStyle(Color("AppAccent"))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
      if let subtitle {
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(Color("AppTextSecondary"))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .depthCard(cornerRadius: 16, elevation: .raised)
    .depthTopSheen(cornerRadius: 16)
    .padding(.horizontal, 16)
    .padding(.top, 8)
  }
}

struct FailFlashOverlay: View {
    @Binding var isVisible: Bool

  var body: some View {
    Color.red
      .opacity(isVisible ? 0.6 : 0)
      .ignoresSafeArea()
      .allowsHitTesting(false)
      .animation(.easeInOut(duration: 0.3), value: isVisible)
  }
}
