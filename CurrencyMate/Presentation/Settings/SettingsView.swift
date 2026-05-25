import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: themeBinding) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
            }

            Section("Rates") {
                Label("Powered by Frankfurter", systemImage: "antenna.radiowaves.left.and.right")
                Text("CurrencyMate uses live exchange rates from the API.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { viewModel.settings.theme },
            set: { viewModel.updateTheme($0) }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(viewModel: HomeViewModel())
        }
    }
}
