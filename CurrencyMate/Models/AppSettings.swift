import Foundation

struct AppSettings: Codable, Hashable {
    var theme: AppTheme

    static let `default` = AppSettings(theme: .system)
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
