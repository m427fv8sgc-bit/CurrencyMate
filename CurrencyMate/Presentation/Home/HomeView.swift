import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                ConverterCard(
                    currencies: viewModel.currencies,
                    amountText: $viewModel.amountText,
                    fromCurrency: $viewModel.fromCurrency,
                    toCurrency: $viewModel.toCurrency,
                    isLoading: viewModel.isLoading,
                    swapAction: viewModel.swapCurrencies,
                    convertAction: viewModel.convert
                )
                ResultCard(
                    convertedAmountText: viewModel.convertedAmountText,
                    rateText: viewModel.rateText
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("CurrencyMate")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(viewModel: viewModel)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .alert("CurrencyMate", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
