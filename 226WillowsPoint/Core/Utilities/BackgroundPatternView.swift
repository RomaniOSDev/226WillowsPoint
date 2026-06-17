import SwiftUI

struct BackgroundPatternView: View {
  var body: some View {
    ZStack {
      AppGradients.background

      RadialGradient(
        colors: [Color("AppPrimary").opacity(0.07), Color.clear],
        center: .topTrailing,
        startRadius: 20,
        endRadius: 280
      )

      RadialGradient(
        colors: [Color("AppAccent").opacity(0.05), Color.clear],
        center: .bottomLeading,
        startRadius: 10,
        endRadius: 240
      )
    }
    .ignoresSafeArea()
  }
}
