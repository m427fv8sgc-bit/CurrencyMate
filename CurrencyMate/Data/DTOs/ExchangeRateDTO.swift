import Foundation

struct ExchangeRateDTO: Decodable {
    let date: String
    let base: String
    let quote: String
    let rate: Double
}
