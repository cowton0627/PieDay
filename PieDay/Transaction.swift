import Foundation

struct Transaction: Codable, Identifiable, Equatable {
    let id: UUID
    var amount: Decimal
    var category: TransactionCategory
    var date: Date
    var note: String?

    init(id: UUID = UUID(), amount: Decimal, category: TransactionCategory,
         date: Date = Date(), note: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }

    var type: TransactionType { category.isIncome ? .income : .expense }
    var signedAmount: Decimal { type == .income ? amount : -amount }
}

enum Money {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func string(_ value: Decimal) -> String {
        formatter.string(from: value as NSDecimalNumber) ?? "NT$0"
    }

    static func decimal(from text: String?) -> Decimal? {
        guard let text, !text.isEmpty else { return nil }
        let normalized = text.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "NT", with: "", options: .caseInsensitive)
        return Decimal(string: normalized.trimmingCharacters(in: .whitespaces))
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
