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
    @Published var settings = AppSettings.default

    let title = "CurrencyMate"
    let subtitle = "Convert currencies with live rates."
    let currencies = Currency.supported

    private let apiService: CurrencyAPIService
    private let numberFormatter: NumberFormatter

    init(
        apiService: CurrencyAPIService = CurrencyAPIService()
    ) {
        self.apiService = apiService

        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.maximumFractionDigits = 2
        self.numberFormatter.minimumFractionDigits = 0
    }

    func convert() async {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let rate = try await apiService.fetchRate(from: fromCurrency, to: toCurrency)
            showConversion(amount: amount, rate: rate)
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

    func updateTheme(_ theme: AppTheme) {
        settings.theme = theme
    }

    func formattedCurrencyName(for code: String) -> String {
        guard let currency = currencies.first(where: { $0.code == code }) else {
            return code
        }

        return "\(currency.code) - \(currency.name)"
    }

    private func showConversion(amount: Double, rate: ExchangeRate) {
        let convertedAmount = amount * rate.rate
        convertedAmountText = "\(format(amount)) \(rate.baseCode) = \(format(convertedAmount)) \(rate.quoteCode)"

        rateText = "Live rate: 1 \(rate.baseCode) = \(formatRate(rate.rate)) \(rate.quoteCode) • \(rate.date)"
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
