import UIKit

enum TransactionCategory: String, Codable, CaseIterable {
    case salary
    case food
    case loan
    case others

    var displayName: String {
        switch self {
        case .salary: return "薪水"
        case .food:   return "餐飲"
        case .loan:   return "貸款"
        case .others: return "其他"
        }
    }

    var isIncome: Bool { self == .salary }

    var color: UIColor {
        switch self {
        case .salary: return .systemOrange
        case .food:   return .systemBlue
        case .loan:   return .systemYellow
        case .others: return .systemGreen
        }
    }
}
