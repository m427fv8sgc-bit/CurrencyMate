import Foundation

protocol AppSettingsStoring {
    func loadSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
}

struct AppSettingsStore: AppSettingsStoring {
    private static let settingsKey = "app_settings"

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    func loadSettings() -> AppSettings {
        guard let data = userDefaults.data(forKey: Self.settingsKey),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return .default
        }

        return settings
    }

    func saveSettings(_ settings: AppSettings) {
        guard let data = try? encoder.encode(settings) else {
            return
        }

        userDefaults.set(data, forKey: Self.settingsKey)
    }
}
