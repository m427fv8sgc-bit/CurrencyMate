import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var amountText = "1"
    @Published var fromCurrency = "USD"
    @Published var toCurrency = "INR"
    @Published private(set) var convertedAmountText = "Enter an amount and tap Convert."
    @Published private(set) var rateText = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var favorites: [CurrencyPair] = []
    @Published private(set) var recentConversions: [ConversionRecord] = []
    @Published var settings: AppSettings

    let title = "CurrencyMate"
    let subtitle = "Convert currencies with live rates and offline cache."
    let currencies = Currency.supported

    private let convertCurrencyUseCase: ConvertCurrencyUseCase
    private let localStore: CurrencyLocalStore
    private let numberFormatter: NumberFormatter

    init(localStore: CurrencyLocalStore = CurrencyLocalStore()) {
        self.localStore = localStore
        self.convertCurrencyUseCase = ConvertCurrencyUseCase(
            repository: ExchangeRateRepository(
                apiService: ExchangeRateAPIService(),
                localStore: localStore
            )
        )
        self.settings = localStore.loadSettings()
        self.favorites = localStore.loadFavorites()
        self.recentConversions = localStore.loadRecentConversions()

        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 2
        self.numberFormatter.minimumFractionDigits = 0
    }

    var selectedPair: CurrencyPair {
        CurrencyPair(fromCode: fromCurrency, toCode: toCurrency)
    }

    var isSelectedPairFavorite: Bool {
        favorites.contains(selectedPair)
    }

    func convert() async {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await convertCurrencyUseCase.execute(
                amount: amount,
                from: fromCurrency,
                to: toCurrency
            )
            updateResult(result)
            saveRecentConversion(result)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func swapCurrencies() {
        let oldFromCurrency = fromCurrency
        fromCurrency = toCurrency
        toCurrency = oldFromCurrency
        convertedAmountText = "Tap Convert to refresh."
        rateText = ""
    }

    func toggleFavorite() {
        if favorites.contains(selectedPair) {
            favorites.removeAll { $0 == selectedPair }
        } else {
            favorites.insert(selectedPair, at: 0)
        }

        localStore.saveFavorites(favorites)
    }

    func useFavorite(_ pair: CurrencyPair) {
        fromCurrency = pair.fromCode
        toCurrency = pair.toCode
        convertedAmountText = "Tap Convert to refresh."
        rateText = ""
    }

    func updateTheme(_ theme: AppTheme) {
        settings.theme = theme
        localStore.saveSettings(settings)
    }

    func clearHistory() {
        recentConversions = []
        localStore.saveRecentConversions([])
    }

    func formattedCurrencyName(for code: String) -> String {
        guard let currency = currencies.first(where: { $0.code == code }) else {
            return code
        }

        return "\(currency.code) - \(currency.name)"
    }

    private func updateResult(_ result: ConversionResult) {
        convertedAmountText = "\(format(result.amount)) \(result.exchangeRate.baseCode) = \(format(result.convertedAmount)) \(result.exchangeRate.quoteCode)"

        let cacheLabel = result.exchangeRate.isCached ? "Cached" : "Live"
        rateText = "\(cacheLabel) rate: 1 \(result.exchangeRate.baseCode) = \(formatRate(result.exchangeRate.rate)) \(result.exchangeRate.quoteCode) • \(result.exchangeRate.date)"
    }

    private func saveRecentConversion(_ result: ConversionResult) {
        let record = ConversionRecord(
            amount: result.amount,
            fromCode: result.exchangeRate.baseCode,
            toCode: result.exchangeRate.quoteCode,
            result: result.convertedAmount,
            rate: result.exchangeRate.rate,
            usedCachedRate: result.exchangeRate.isCached
        )

        recentConversions.insert(record, at: 0)
        recentConversions = Array(recentConversions.prefix(8))
        localStore.saveRecentConversions(recentConversions)
    }

    private func format(_ value: Double) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    private func formatRate(_ value: Double) -> String {
        if value < 0.01 {
            return String(format: "%.6f", value)
        }

        return format(value)
    }
}
