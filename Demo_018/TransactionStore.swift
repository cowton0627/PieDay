import Foundation

final class TransactionStore {
    static let shared = TransactionStore()
    static let didChangeNotification = Notification.Name("TransactionStore.didChange")

    private(set) var transactions: [Transaction] = []

    private let storageKey = "TransactionStore.transactions.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Mutations
    func add(_ transaction: Transaction) {
        transactions.append(transaction)
        persist()
    }

    func delete(at index: Int) {
        guard transactions.indices.contains(index) else { return }
        transactions.remove(at: index)
        persist()
    }

    func removeAll() {
        transactions.removeAll()
        persist()
    }

    // MARK: - Aggregates
    var balance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    func total(for category: TransactionCategory) -> Double {
        transactions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    /// 每個支出分類佔薪水的百分比；最後 key=nil 代表「剩餘 / 結餘」。
    func expenseRatiosAgainstSalary() -> [(category: TransactionCategory?, ratio: Double)] {
        let salary = total(for: .salary)
        guard salary > 0 else { return [] }

        var result: [(TransactionCategory?, Double)] = []
        var consumed: Double = 0
        for category in TransactionCategory.allCases where !category.isIncome {
            let amount = total(for: category)
            guard amount > 0 else { continue }
            result.append((category, amount / salary))
            consumed += amount
        }
        let remaining = max(0, salary - consumed)
        if remaining > 0 {
            result.append((nil, remaining / salary))
        }
        return result
    }

    // MARK: - Persistence
    private func persist() {
        do {
            let data = try JSONEncoder().encode(transactions)
            defaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to encode transactions: \(error)")
        }
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        do {
            transactions = try JSONDecoder().decode([Transaction].self, from: data)
        } catch {
            assertionFailure("Failed to decode transactions: \(error)")
            transactions = []
        }
    }
}
