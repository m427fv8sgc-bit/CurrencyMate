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
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                Label("Convert", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        //.buttonStyle(.borderedProminent)
        .buttonStyle(MyCustomBtnStyle())
        .disabled(isLoading)
    }
}


