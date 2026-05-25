import Foundation

struct ConversionResult {
    let amount: Double
    let convertedAmount: Double
    let exchangeRate: ExchangeRate
}

struct ConvertCurrencyUseCase {
    private let repository: ExchangeRateRepositoryProtocol

    init(repository: ExchangeRateRepositoryProtocol) {
        self.repository = repository
    }

    func execute(amount: Double, from baseCode: String, to quoteCode: String) async throws -> ConversionResult {
        if baseCode == quoteCode {
            let rate = ExchangeRate(
                baseCode: baseCode,
                quoteCode: quoteCode,
                rate: 1,
                date: "Today",
                isCached: false
            )
            return ConversionResult(amount: amount, convertedAmount: amount, exchangeRate: rate)
        }

        let rate = try await repository.rate(from: baseCode, to: quoteCode)
        return ConversionResult(
            amount: amount,
            convertedAmount: amount * rate.rate,
            exchangeRate: rate
        )
    }
}
