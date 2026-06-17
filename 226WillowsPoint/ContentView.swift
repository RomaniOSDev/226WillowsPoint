import SwiftUI

struct ContentView: View {
    @StateObject private var storage = AppStorage.shared

  var body: some View {
    Group {
      if storage.hasSeenOnboarding {
        MainTabView()
      } else {
        OnboardingView()
      }
    }
    .environmentObject(storage)
    .preferredColorScheme(.dark)
  }
}

#Preview {
    ContentView()
}
