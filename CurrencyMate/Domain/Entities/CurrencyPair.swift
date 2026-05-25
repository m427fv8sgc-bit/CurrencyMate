import Foundation

struct CurrencyPair: Identifiable, Hashable, Codable {
    let fromCode: String
    let toCode: String

    var id: String {
        "\(fromCode)-\(toCode)"
    }
}
