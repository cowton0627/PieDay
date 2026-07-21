import Foundation

struct Transaction: Codable, Identifiable {
    let id: UUID
    let amount: Double
    let category: TransactionCategory
    let date: Date
    let note: String?

    init(id: UUID = UUID(),
         amount: Double,
         category: TransactionCategory,
         date: Date = Date(),
         note: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }

    var type: TransactionType {
        category.isIncome ? .income : .expense
    }

    var signedAmount: Double {
        type == .income ? amount : -amount
    }
}
