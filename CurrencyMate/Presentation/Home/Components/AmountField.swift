import SwiftUI

struct AmountField: View {
    let symbol: String
    @Binding var amountText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Text(symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32)

                Divider()
                    .frame(height: 28)

                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.title2.weight(.semibold))
                    .accessibilityLabel("Amount")
            }
            .controlSurface()
        }
    }
}
