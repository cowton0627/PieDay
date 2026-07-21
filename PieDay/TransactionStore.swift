import Foundation

final class TransactionStore {
    static let shared = TransactionStore()
    static let didChangeNotification = Notification.Name("TransactionStore.didChange")

    private(set) var transactions: [Transaction] = []
    private(set) var monthlyBudgets: [TransactionCategory: Decimal] = [:]

    private let transactionKey = "TransactionStore.transactions.v1"
    private let budgetKey = "TransactionStore.budgets.v1"
    private let defaults: UserDefaults
    private let calendar: Calendar

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
        load()
    }

    func add(_ transaction: Transaction) {
        transactions.append(transaction)
        saveAndNotify()
    }

    func update(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
        saveAndNotify()
    }

    func delete(id: UUID) {
        transactions.removeAll { $0.id == id }
        saveAndNotify()
    }

    func delete(at index: Int) {
        guard transactions.indices.contains(index) else { return }
        transactions.remove(at: index)
        saveAndNotify()
    }

    func setBudget(_ amount: Decimal, for category: TransactionCategory) {
        guard !category.isIncome else { return }
        monthlyBudgets[category] = max(0, amount)
        saveAndNotify()
    }

    func budget(for category: TransactionCategory) -> Decimal { monthlyBudgets[category] ?? 0 }

    func transactions(in month: Date = Date()) -> [Transaction] {
        transactions.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    func total(type: TransactionType, in month: Date = Date()) -> Decimal {
        transactions(in: month).filter { $0.type == type }.reduce(0) { $0 + $1.amount }
    }

    func total(for category: TransactionCategory, in month: Date = Date()) -> Decimal {
        transactions(in: month).filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }

    var balance: Decimal { transactions.reduce(0) { $0 + $1.signedAmount } }
    var monthlyIncome: Decimal { total(type: .income) }
    var monthlyExpense: Decimal { total(type: .expense) }
    var monthlyBalance: Decimal { monthlyIncome - monthlyExpense }
    var totalBudget: Decimal { monthlyBudgets.values.reduce(0, +) }

    func budgetProgress(for category: TransactionCategory) -> Double {
        let budget = budget(for: category)
        guard budget > 0 else { return 0 }
        return NSDecimalNumber(decimal: total(for: category) / budget).doubleValue
    }

    func spendingBreakdown() -> [(category: TransactionCategory, amount: Decimal)] {
        TransactionCategory.expenseCases.compactMap { category in
            let amount = total(for: category)
            return amount > 0 ? (category, amount) : nil
        }.sorted { $0.amount > $1.amount }
    }

    func loadDemoData() {
        let now = Date()
        let day: TimeInterval = 86_400
        transactions = [
            Transaction(amount: 58_000, category: .salary, date: now.addingTimeInterval(-18 * day), note: "七月薪資"),
            Transaction(amount: 16_500, category: .housing, date: now.addingTimeInterval(-17 * day), note: "房租"),
            Transaction(amount: 1_280, category: .subscription, date: now.addingTimeInterval(-12 * day), note: "軟體與影音"),
            Transaction(amount: 3_420, category: .food, date: now.addingTimeInterval(-8 * day), note: "本週餐飲"),
            Transaction(amount: 1_150, category: .transport, date: now.addingTimeInterval(-5 * day), note: "捷運與計程車"),
            Transaction(amount: 2_680, category: .shopping, date: now.addingTimeInterval(-2 * day), note: "生活用品"),
            Transaction(amount: 900, category: .entertainment, date: now, note: "電影與聚餐")
        ]
        monthlyBudgets = [.food: 8_000, .transport: 3_000, .housing: 18_000,
                          .shopping: 5_000, .entertainment: 4_000, .subscription: 2_000,
                          .health: 3_000, .education: 3_000, .others: 2_000]
        saveAndNotify()
    }

    func removeAll() {
        transactions.removeAll()
        monthlyBudgets.removeAll()
        saveAndNotify()
    }

    private func saveAndNotify() {
        if let data = try? JSONEncoder().encode(transactions) { defaults.set(data, forKey: transactionKey) }
        let rawBudgets = Dictionary(uniqueKeysWithValues: monthlyBudgets.map { ($0.key.rawValue, $0.value) })
        if let data = try? JSONEncoder().encode(rawBudgets) { defaults.set(data, forKey: budgetKey) }
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

    private func load() {
        if let data = defaults.data(forKey: transactionKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
        if let data = defaults.data(forKey: budgetKey),
           let decoded = try? JSONDecoder().decode([String: Decimal].self, from: data) {
            monthlyBudgets = Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
                TransactionCategory(rawValue: key).map { ($0, value) }
            })
        }
    }
}
