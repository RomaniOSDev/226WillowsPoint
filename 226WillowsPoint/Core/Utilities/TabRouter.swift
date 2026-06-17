import Foundation
import Combine

final class TabRouter: ObservableObject {
    @Published var selectedTab: MainTab = .home

    func switchTo(_ tab: MainTab) {
        selectedTab = tab
    }
}
