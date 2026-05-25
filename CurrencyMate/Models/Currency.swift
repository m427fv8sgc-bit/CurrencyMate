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
//        Currency(code: "JPY", name: "Japanese Yen", symbol: "¥"),
//        Currency(code: "AUD", name: "Australian Dollar", symbol: "A$"),
//        Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$"),
//        Currency(code: "CHF", name: "Swiss Franc", symbol: "CHF"),
//        Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥"),
//        Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$")
    ]
}
