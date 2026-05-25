import Foundation

final class CurrencyStorage {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveRate(_ rate: ExchangeRate) {
        save(rate, key: "rate_\(rate.baseCode)_\(rate.quoteCode)")
    }

    func loadRate(for pair: CurrencyPair) -> ExchangeRate? {
        load(ExchangeRate.self, key: "rate_\(pair.fromCode)_\(pair.toCode)")
    }

    func saveFavorites(_ favorites: [CurrencyPair]) {
        save(favorites, key: "favorites")
    }

    func loadFavorites() -> [CurrencyPair] {
        load([CurrencyPair].self, key: "favorites") ?? []
    }

    func saveRecentConversions(_ records: [ConversionRecord]) {
        save(records, key: "recent_conversions")
    }

    func loadRecentConversions() -> [ConversionRecord] {
        load([ConversionRecord].self, key: "recent_conversions") ?? []
    }

    func saveSettings(_ settings: AppSettings) {
        save(settings, key: "settings")
    }

    func loadSettings() -> AppSettings {
        load(AppSettings.self, key: "settings") ?? .default
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
