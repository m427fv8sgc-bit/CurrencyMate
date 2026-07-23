import Foundation

struct ExchangeRate: Codable {
    let baseCode: String
    let quoteCode: String
    let rate: Double
    let date: Date

    enum CodingKeys: String, CodingKey {
        case baseCode = "base"
        case quoteCode = "quote"
        case rate
        case date
    }
}
