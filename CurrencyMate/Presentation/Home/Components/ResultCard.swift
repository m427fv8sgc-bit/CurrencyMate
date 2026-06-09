import SwiftUI

struct ResultCard: View {
    let convertedAmountText: String
    let rateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)

            Text(convertedAmountText)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            if !rateText.isEmpty {
                Text(rateText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .cardStyle()
    }
}
