import Foundation

final class CurrencyLocalStore {
    private enum Key {
        static let favorites = "currencymate.favorites"
        static let recentConversions = "currencymate.recentConversions"
        static let settings = "currencymate.settings"

        static func rate(_ pair: CurrencyPair) -> String {
            "currencymate.rate.\(pair.id)"
        }
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func cachedRate(for pair: CurrencyPair) -> ExchangeRate? {
        read(ExchangeRate.self, forKey: Key.rate(pair))
    }

    func saveRate(_ rate: ExchangeRate) {
        let pair = CurrencyPair(fromCode: rate.baseCode, toCode: rate.quoteCode)
        write(rate, forKey: Key.rate(pair))
    }

    func loadFavorites() -> [CurrencyPair] {
        read([CurrencyPair].self, forKey: Key.favorites) ?? []
    }

    func saveFavorites(_ favorites: [CurrencyPair]) {
        write(favorites, forKey: Key.favorites)
    }

    func loadRecentConversions() -> [ConversionRecord] {
        read([ConversionRecord].self, forKey: Key.recentConversions) ?? []
    }

    func saveRecentConversions(_ records: [ConversionRecord]) {
        write(records, forKey: Key.recentConversions)
    }

    func loadSettings() -> AppSettings {
        read(AppSettings.self, forKey: Key.settings) ?? .default
    }

    func saveSettings(_ settings: AppSettings) {
        write(settings, forKey: Key.settings)
    }

    private func read<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func write<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        userDefaults.set(data, forKey: key)
    }
}
