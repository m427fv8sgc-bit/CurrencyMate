import Foundation

struct ExchangeRateRepository: ExchangeRateRepositoryProtocol {
    private let apiService: ExchangeRateAPIService
    private let localStore: CurrencyLocalStore

    init(apiService: ExchangeRateAPIService, localStore: CurrencyLocalStore) {
        self.apiService = apiService
        self.localStore = localStore
    }

    func rate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate {
        let pair = CurrencyPair(fromCode: baseCode, toCode: quoteCode)

        do {
            let dto = try await apiService.fetchRate(from: baseCode, to: quoteCode)
            let freshRate = ExchangeRate(
                baseCode: dto.base,
                quoteCode: dto.quote,
                rate: dto.rate,
                date: dto.date,
                isCached: false
            )
            localStore.saveRate(freshRate)
            return freshRate
        } catch {
            if let cachedRate = localStore.cachedRate(for: pair) {
                return ExchangeRate(
                    baseCode: cachedRate.baseCode,
                    quoteCode: cachedRate.quoteCode,
                    rate: cachedRate.rate,
                    date: cachedRate.date,
                    isCached: true
                )
            }

            throw error
        }
    }
}
