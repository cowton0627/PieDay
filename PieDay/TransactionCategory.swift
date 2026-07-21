import UIKit

enum TransactionCategory: String, Codable, CaseIterable {
    case salary, bonus
    case food, transport, housing, loan, shopping, entertainment, health, education, subscription, others

    static var incomeCases: [Self] { allCases.filter(\.isIncome) }
    static var expenseCases: [Self] { allCases.filter { !$0.isIncome } }

    var displayName: String {
        switch self {
        case .salary: return "薪資"
        case .bonus: return "其他收入"
        case .food: return "餐飲"
        case .transport: return "交通"
        case .housing: return "居住"
        case .loan: return "貸款"
        case .shopping: return "購物"
        case .entertainment: return "娛樂"
        case .health: return "健康"
        case .education: return "學習"
        case .subscription: return "訂閱"
        case .others: return "其他"
        }
    }

    var symbolName: String {
        switch self {
        case .salary: return "banknote.fill"
        case .bonus: return "sparkles"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .loan: return "creditcard.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .subscription: return "repeat.circle.fill"
        case .others: return "ellipsis.circle.fill"
        }
    }

    var isIncome: Bool { self == .salary || self == .bonus }

    var color: UIColor {
        switch self {
        case .salary, .bonus: return .systemGreen
        case .food: return .systemOrange
        case .transport: return .systemBlue
        case .housing: return .systemIndigo
        case .loan: return .systemBrown
        case .shopping: return .systemPink
        case .entertainment: return .systemPurple
        case .health: return .systemRed
        case .education: return .systemTeal
        case .subscription: return .systemCyan
        case .others: return .systemGray
        }
    }
}
