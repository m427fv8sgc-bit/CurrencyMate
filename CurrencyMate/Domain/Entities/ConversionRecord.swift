import Foundation

struct ConversionRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let amount: Double
    let fromCode: String
    let toCode: String
    let result: Double
    let rate: Double
    let date: Date
    let usedCachedRate: Bool

    init(
        id: UUID = UUID(),
        amount: Double,
        fromCode: String,
        toCode: String,
        result: Double,
        rate: Double,
        date: Date = Date(),
        usedCachedRate: Bool
    ) {
        self.id = id
        self.amount = amount
        self.fromCode = fromCode
        self.toCode = toCode
        self.result = result
        self.rate = rate
        self.date = date
        self.usedCachedRate = usedCachedRate
    }
}
