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
//    @Published private(set) var favorites: [CurrencyPair] = []
//    @Published private(set) var recentConversions: [ConversionRecord] = []
    @Published var settings: AppSettings

    let title = "CurrencyMate"
    let subtitle = "Convert currencies with live rates and offline cache."
    let currencies = Currency.supported

    private let apiService: CurrencyAPIService
    private let storage: CurrencyStorage
    private let numberFormatter: NumberFormatter

    init(
        apiService: CurrencyAPIService = CurrencyAPIService(),
        storage: CurrencyStorage = CurrencyStorage()
    ) {
        self.apiService = apiService
        self.storage = storage
        self.settings = storage.loadSettings()
//        self.favorites = storage.loadFavorites()
//        self.recentConversions = storage.loadRecentConversions()

        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 2
        self.numberFormatter.minimumFractionDigits = 0
    }

    var selectedPair: CurrencyPair {
        CurrencyPair(fromCode: fromCurrency, toCode: toCurrency)
    }

//    var isSelectedPairFavorite: Bool {
//        favorites.contains(selectedPair)
//    }

    func convert() async {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let rate = try await apiService.fetchRate(from: fromCurrency, to: toCurrency)
            storage.saveRate(rate)
            showConversion(amount: amount, rate: rate)
        } catch {
            if let cachedRate = storage.loadRate(for: selectedPair) {
                let rate = ExchangeRate(
                    baseCode: cachedRate.baseCode,
                    quoteCode: cachedRate.quoteCode,
                    rate: cachedRate.rate,
                    date: cachedRate.date,
                    isCached: true
                )
                showConversion(amount: amount, rate: rate)
            } else {
                errorMessage = error.localizedDescription
            }
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

//    func toggleFavorite() {
//        if favorites.contains(selectedPair) {
//            favorites.removeAll { $0 == selectedPair }
//        } else {
//            favorites.insert(selectedPair, at: 0)
//        }
//
//        storage.saveFavorites(favorites)
//    }
//
//    func useFavorite(_ pair: CurrencyPair) {
//        fromCurrency = pair.fromCode
//        toCurrency = pair.toCode
//        convertedAmountText = "Tap Convert to refresh."
//        rateText = ""
//    }

    func updateTheme(_ theme: AppTheme) {
        settings.theme = theme
        storage.saveSettings(settings)
    }

//    func clearHistory() {
//        recentConversions = []
//        storage.saveRecentConversions([])
//    }

    func formattedCurrencyName(for code: String) -> String {
        guard let currency = currencies.first(where: { $0.code == code }) else {
            return code
        }

        return "\(currency.code) - \(currency.name)"
    }

    private func showConversion(amount: Double, rate: ExchangeRate) {
        let convertedAmount = amount * rate.rate
        convertedAmountText = "\(format(amount)) \(rate.baseCode) = \(format(convertedAmount)) \(rate.quoteCode)"

        let cacheLabel = rate.isCached ? "Cached" : "Live"
        rateText = "\(cacheLabel) rate: 1 \(rate.baseCode) = \(formatRate(rate.rate)) \(rate.quoteCode) • \(rate.date)"
//        saveRecentConversion(amount: amount, convertedAmount: convertedAmount, rate: rate)
    }

//    private func saveRecentConversion(amount: Double, convertedAmount: Double, rate: ExchangeRate) {
//        let record = ConversionRecord(
//            amount: amount,
//            fromCode: rate.baseCode,
//            toCode: rate.quoteCode,
//            result: convertedAmount,
//            rate: rate.rate,
//            usedCachedRate: rate.isCached
//        )
//
//        recentConversions.insert(record, at: 0)
//        recentConversions = Array(recentConversions.prefix(8))
//        storage.saveRecentConversions(recentConversions)
//    }

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
