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
                favoritesCard
                recentConversionsCard
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
            Text(viewModel.title)
                .font(.largeTitle.bold())

            Text(viewModel.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var converterCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Converter")
                .font(.headline)

            TextField("Amount", text: $viewModel.amountText)
                .keyboardType(.decimalPad)
                .font(.title2.weight(.semibold))
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityLabel("Amount")

            currencyPicker(title: "From", selection: $viewModel.fromCurrency)

            HStack {
                Spacer()
                Button {
                    viewModel.swapCurrencies()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Swap currencies")
                Spacer()
            }

            currencyPicker(title: "To", selection: $viewModel.toCurrency)

            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.convert()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Convert", systemImage: "arrow.right.circle.fill")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isSelectedPairFavorite ? "star.fill" : "star")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(viewModel.isSelectedPairFavorite ? "Remove favorite" : "Add favorite")
            }
        }
        .cardStyle()
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

    @ViewBuilder
    private var favoritesCard: some View {
        if !viewModel.favorites.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Favorites")
                    .font(.headline)

                ForEach(viewModel.favorites) { pair in
                    Button {
                        viewModel.useFavorite(pair)
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("\(pair.fromCode) -> \(pair.toCode)")
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .cardStyle()
        }
    }

    @ViewBuilder
    private var recentConversionsCard: some View {
        if !viewModel.recentConversions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(.headline)

                ForEach(viewModel.recentConversions) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(formatted(record.amount)) \(record.fromCode) -> \(formatted(record.result)) \(record.toCode)")
                            .font(.subheadline.weight(.semibold))

                        Text(record.usedCachedRate ? "Offline cached rate" : "Live rate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
            }
            .cardStyle()
        }
    }

    private func currencyPicker(title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker(title, selection: selection) {
                ForEach(viewModel.currencies) { currency in
                    Text("\(currency.code) - \(currency.name)")
                        .tag(currency.code)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
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

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}

private extension View {
    func cardStyle() -> some View {
        padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
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
