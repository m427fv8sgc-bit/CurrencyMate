import SwiftUI

struct SwapButton: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Divider()

            Button(action: action) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.headline)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
            .accessibilityLabel("Swap currencies")

            Divider()
        }
        .frame(height: 36)
    }
}
