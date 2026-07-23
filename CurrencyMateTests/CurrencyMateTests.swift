import XCTest
@testable import CurrencyMate

@MainActor
final class HomeViewModelTests: XCTestCase {

    func testConvertUpdatesResultTextWhenRateLoads() async {
        let rateDate = makeDate(year: 2020, month: 1, day: 15)
        let rateService = CurrencyRateFetchingSpy(
            result: ExchangeRate(
                baseCode: "USD",
                quoteCode: "INR",
                rate: 82.5,
                date: rateDate
            )
        )
        let viewModel = makeViewModel(apiService: rateService)

        viewModel.amountText = "2"
        viewModel.fromCurrency = "USD"
        viewModel.toCurrency = "INR"

        await viewModel.convert()

        XCTAssertEqual(rateService.requestedBaseCode, "USD")
        XCTAssertEqual(rateService.requestedQuoteCode, "INR")
        XCTAssertEqual(viewModel.convertedAmountText, "2 USD = 165 INR")
        XCTAssertTrue(viewModel.rateText.contains("Live rate: 1 USD = 82.5 INR"))
        XCTAssertTrue(viewModel.rateText.contains(formattedDate(rateDate)))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testConvertShowsErrorForInvalidAmount() async {
        let rateService = CurrencyRateFetchingSpy(result: makeExchangeRate())
        let viewModel = makeViewModel(apiService: rateService)

        viewModel.amountText = "0"

        await viewModel.convert()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid amount.")
        XCTAssertNil(rateService.requestedBaseCode)
        XCTAssertNil(rateService.requestedQuoteCode)
        XCTAssertFalse(viewModel.isLoading)
    }



    private func makeViewModel(
        apiService: CurrencyRateFetching? = nil,
        settingsStore: AppSettingsStoring = AppSettingsStoreSpy(settings: .default)
    ) -> HomeViewModel {
        HomeViewModel(
            apiService: apiService ?? CurrencyRateFetchingSpy(result: makeExchangeRate()),
            settingsStore: settingsStore
        )
    }

    private func makeExchangeRate() -> ExchangeRate {
        ExchangeRate(
            baseCode: "USD",
            quoteCode: "INR",
            rate: 82.5,
            date: makeDate(year: 2020, month: 1, day: 15)
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day

        return components.date!
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private final class CurrencyRateFetchingSpy: CurrencyRateFetching {
    private let result: ExchangeRate
    private(set) var requestedBaseCode: String?
    private(set) var requestedQuoteCode: String?

    init(result: ExchangeRate) {
        self.result = result
    }

    func fetchRate(from baseCode: String, to quoteCode: String) async throws -> ExchangeRate {
        requestedBaseCode = baseCode
        requestedQuoteCode = quoteCode
        return result
    }
}

private final class AppSettingsStoreSpy: AppSettingsStoring {
    private let settings: AppSettings
    private(set) var savedSettings: AppSettings?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func loadSettings() -> AppSettings {
        settings
    }

    func saveSettings(_ settings: AppSettings) {
        savedSettings = settings
    }
}
