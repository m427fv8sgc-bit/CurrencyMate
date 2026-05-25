import Foundation

protocol ExchangeRateRepositoryProtocol {
    func rate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate
}
