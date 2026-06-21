import SwiftUI

struct ConvertButton: View {
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if isLoading {
                ProgressView()
            } else {
                Label("Convert", systemImage: "arrow.right.circle.fill")
            }
        }
        .buttonStyle(.primaryAction)
        .disabled(isLoading)
    }
}

