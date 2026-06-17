import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var showResetAlert = false

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundPatternView()

        ScrollView {
          VStack(spacing: 20) {
            ScreenHeaderView(
              title: "Settings",
              subtitle: "Track your progress and manage your adventure data."
            )

            statsSection

            SectionHeaderView(title: "Legal")

            SettingsActionCell(title: "Rate Us", icon: "star.bubble.fill") {
              HapticManager.lightTap()
              rateApp()
            }

            SettingsActionCell(title: "Privacy Policy", icon: "hand.raised.fill") {
              HapticManager.lightTap()
              openLink(.privacyPolicy)
            }

            SettingsActionCell(title: "Terms", icon: "doc.text.fill") {
              HapticManager.lightTap()
              openLink(.terms)
            }

            SectionHeaderView(title: "Data")

            SettingsActionCell(title: "Reset All Progress", icon: "trash.fill", isDestructive: true) {
              HapticManager.lightTap()
              showResetAlert = true
            }

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
              .font(.caption)
              .foregroundStyle(Color("AppTextSecondary"))
              .frame(maxWidth: .infinity)
              .padding(.top, 8)
          }
          .padding(16)
          .padding(.bottom, 100)
        }
      }
      .alert("Reset All Progress?", isPresented: $showResetAlert) {
        Button("Cancel", role: .cancel) {
          HapticManager.lightTap()
        }
        Button("Reset", role: .destructive) {
          HapticManager.mediumTap()
          storage.resetAllProgress()
        }
      } message: {
        Text("This will erase all your stars, levels, and achievements. This cannot be undone.")
      }
    }
  }

  private var statsSection: some View {
    CustomCard {
      VStack(spacing: 0) {
        SettingsStatCell(icon: "gamecontroller.fill", label: "Activities Played", value: "\(storage.totalActivitiesPlayed)")
        divider
        SettingsStatCell(icon: "star.fill", label: "Total STARS", value: "\(storage.totalStarsEarned)")
        divider
        SettingsStatCell(icon: "book.fill", label: "Runes Discovered", value: "\(storage.discoveredRuneCount)/\(RuneDefinition.catalog.count)")
        divider
        SettingsStatCell(icon: "map.fill", label: "Path Nodes Cleared", value: "\(storage.completedPathNodeCount)/\(PathMapNode.allNodes.count)")
        divider
        SettingsStatCell(icon: "flame.fill", label: "Daily Streak", value: "\(storage.dailyChallengeStreak)")
        divider
        SettingsStatCell(icon: "clock.fill", label: "Play Time", value: storage.formattedPlayTime)
      }
      .padding(.vertical, 4)
    }
  }

  private var divider: some View {
    Rectangle()
      .fill(Color("AppTextSecondary").opacity(0.12))
      .frame(height: 1)
      .padding(.horizontal, 14)
  }

  private func openLink(_ link: AppLinks) {
    if let url = link.url {
      UIApplication.shared.open(url)
    }
  }

  private func rateApp() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      SKStoreReviewController.requestReview(in: windowScene)
    }
  }
}
