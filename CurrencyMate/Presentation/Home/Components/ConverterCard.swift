import SwiftUI

struct ConverterCard: View {
    let currencies: [Currency]
    @Binding var amountText: String
    @Binding var fromCurrency: String
    @Binding var toCurrency: String
    let isLoading: Bool
    let swapAction: () -> Void
    let convertAction: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            AmountField(
                symbol: symbol(for: fromCurrency),
                amountText: $amountText
            )
            CurrencyPickerField(
                title: "From",
                currencies: currencies,
                selection: $fromCurrency
            )
            SwapButton(action: swapAction)
            CurrencyPickerField(
                title: "To",
                currencies: currencies,
                selection: $toCurrency
            )
            ConvertButton(
                isLoading: isLoading,
                action: convertAction
            )
        }
        .cardStyle()
    }

    private var header: some View {
        HStack {
            Text("Converter")
                .font(.headline)

            Spacer()

            Label("Live", systemImage: "antenna.radiowaves.left.and.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func symbol(for code: String) -> String {
        currencies.first { $0.code == code }?.symbol ?? code
    }
}
