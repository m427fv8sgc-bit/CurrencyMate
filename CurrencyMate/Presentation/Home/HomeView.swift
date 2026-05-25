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
                converterCard
                resultCard
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

    private var converterCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Converter")
                    .font(.headline)

                Spacer()

                Label("Live", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            amountField
            CurrencyPickerField(
                title: "From",
                currencies: viewModel.currencies,
                selection: $viewModel.fromCurrency
            )
            swapButton
            CurrencyPickerField(
                title: "To",
                currencies: viewModel.currencies,
                selection: $viewModel.toCurrency
            )
            convertButton
        }
        .cardStyle()
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Text(symbol(for: viewModel.fromCurrency))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32)

                Divider()
                    .frame(height: 28)

                TextField("0.00", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .font(.title2.weight(.semibold))
                    .accessibilityLabel("Amount")
            }
            .controlSurface()
        }
    }

    private var swapButton: some View {
        HStack(spacing: 12) {
            Divider()

            Button {
                viewModel.swapCurrencies()
            } label: {
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

    private var convertButton: some View {
        Button {
            Task {
                await viewModel.convert()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                Label("Convert", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading)
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)

            Text(viewModel.convertedAmountText)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            if !viewModel.rateText.isEmpty {
                Text(viewModel.rateText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .cardStyle()
    }

    private func symbol(for code: String) -> String {
        viewModel.currencies.first { $0.code == code }?.symbol ?? code
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

private struct CurrencyPickerField: View {
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

private extension View {
    func cardStyle() -> some View {
        padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    func controlSurface() -> some View {
        padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
