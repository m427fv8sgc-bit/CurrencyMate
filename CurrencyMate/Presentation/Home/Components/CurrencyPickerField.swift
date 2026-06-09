import SwiftUI

struct CurrencyPickerField: View {
    let title: String
    let currencies: [Currency]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Picker(selection: $selection) {
                ForEach(currencies) { currency in
                    Text("\(currency.code) - \(currency.name)")
                        .tag(currency.code)
                }
            } label: {
                HStack(spacing: 12) {
                    Text(symbol(for: selection))
                        .font(.headline)
                        .frame(width: 32, height: 32)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selection)
                            .font(.body.weight(.semibold))

                        Text(currencyName(for: selection))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .controlSurface()
        }
    }

    private func symbol(for code: String) -> String {
        currencies.first { $0.code == code }?.symbol ?? code
    }

    private func currencyName(for code: String) -> String {
        currencies.first { $0.code == code }?.name ?? code
    }
}
