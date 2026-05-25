import Foundation

struct ExchangeRate: Codable, Hashable {
    let baseCode: String
    let quoteCode: String
    let rate: Double
    let date: String
    let isCached: Bool
}
