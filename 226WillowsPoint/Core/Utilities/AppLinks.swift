import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://willowspoint226.site/privacy/273"
    case terms = "https://willowspoint226.site/terms/273"

    var url: URL? {
        URL(string: rawValue)
    }
}
