import Foundation

struct Currency: Identifiable, Hashable, Codable {
    let id: String
    let code: String
    let name: String
    let symbol: String

    init(code: String, name: String, symbol: String) {
        self.id = code
        self.code = code
        self.name = name
        self.symbol = symbol
    }
}

extension Currency {
    static let supported: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$"),
        Currency(code: "INR", name: "Indian Rupee", symbol: "₹"),
        Currency(code: "EUR", name: "Euro", symbol: "€"),
        Currency(code: "GBP", name: "British Pound", symbol: "£"),
    ]
}
