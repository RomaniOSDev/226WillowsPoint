import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case map
    case codex
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Map"
        case .codex: return "Codex"
        case .achievements: return "Awards"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .codex: return "book.fill"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @StateObject private var tabRouter = TabRouter()

  var body: some View {
    ZStack(alignment: .bottom) {
      Group {
        switch tabRouter.selectedTab {
        case .home:
          HomeView()
        case .map:
          PathMapView()
        case .codex:
          RuneCodexView()
        case .achievements:
          AchievementsView()
        case .settings:
          SettingsView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .environmentObject(tabRouter)

      CustomTabBar(selectedTab: $tabRouter.selectedTab)
    }
    .background(Color("AppBackground"))
  }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

  var body: some View {
    HStack(spacing: 4) {
      ForEach(MainTab.allCases, id: \.rawValue) { tab in
        Button {
          HapticManager.lightTap()
          withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedTab = tab
          }
        } label: {
          VStack(spacing: 4) {
            ZStack {
              if selectedTab == tab {
                Circle()
                  .fill(AppGradients.primaryVertical)
                  .frame(width: 34, height: 34)
                  .shadow(color: Color("AppPrimary").opacity(0.45), radius: 6, y: 2)
              }
              Image(systemName: tab.iconName)
                .font(.system(size: selectedTab == tab ? 18 : 16, weight: .semibold))
                .foregroundStyle(selectedTab == tab ? Color("AppBackground") : Color("AppTextSecondary"))
            }
            Text(tab.title)
              .font(.system(size: 9, weight: .semibold))
              .lineLimit(1)
              .minimumScaleFactor(0.6)
              .foregroundStyle(selectedTab == tab ? Color("AppPrimary") : Color("AppTextSecondary"))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 6)
        }
        .buttonStyle(ScaleButtonStyle())
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(AppGradients.surfaceHighlight)
        .overlay {
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(AppGradients.subtleBorder, lineWidth: 1)
        }
    }
    .depthTopSheen(cornerRadius: 24)
    .compositingGroup()
    .shadow(color: Color.black.opacity(0.45), radius: 16, y: -2)
    .padding(.horizontal, 12)
    .padding(.bottom, 4)
  }
}
