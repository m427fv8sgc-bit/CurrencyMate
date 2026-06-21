import SwiftUI

struct SwapButton: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Divider()

            Button(action: action) {
                Image(systemName: "arrow.up.arrow.down")
            }
            .buttonStyle(.currencyIcon)
            .accessibilityLabel("Swap currencies")

            Divider()
        }
        .frame(height: 44)
    }
}
