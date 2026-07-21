import Foundation

final class TransactionStore {
    struct MonthlySummary: Equatable {
        let month: Date
        let income: Decimal
        let expense: Decimal
    }

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

    func budgetProgress(for category: TransactionCategory, in month: Date = Date()) -> Double {
        let budget = budget(for: category)
        guard budget > 0 else { return 0 }
        return NSDecimalNumber(decimal: total(for: category, in: month) / budget).doubleValue
    }

    func spendingBreakdown(in month: Date = Date()) -> [(category: TransactionCategory, amount: Decimal)] {
        TransactionCategory.expenseCases.compactMap { category in
            let amount = total(for: category, in: month)
            return amount > 0 ? (category, amount) : nil
        }.sorted { $0.amount > $1.amount }
    }

    func monthlySummaries(endingAt month: Date = Date(), count: Int = 6) -> [MonthlySummary] {
        guard count > 0 else { return [] }
        let end = calendar.dateInterval(of: .month, for: month)?.start ?? month
        return (0..<count).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: end) else { return nil }
            return MonthlySummary(month: date,
                                  income: total(type: .income, in: date),
                                  expense: total(type: .expense, in: date))
        }
    }

    func loadDemoData() {
        let now = Date()
        func date(monthOffset: Int, day: Int) -> Date {
            let shifted = calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now
            var components = calendar.dateComponents([.year, .month], from: shifted)
            components.day = day
            return calendar.date(from: components) ?? shifted
        }
        transactions = [
            Transaction(amount: 58_000, category: .salary, date: date(monthOffset: 0, day: 3), note: "本月薪資"),
            Transaction(amount: 16_500, category: .housing, date: date(monthOffset: 0, day: 4), note: "房租"),
            Transaction(amount: 1_280, category: .subscription, date: date(monthOffset: 0, day: 9), note: "軟體與影音"),
            Transaction(amount: 3_420, category: .food, date: date(monthOffset: 0, day: 13), note: "本週餐飲"),
            Transaction(amount: 1_150, category: .transport, date: date(monthOffset: 0, day: 16), note: "捷運與計程車"),
            Transaction(amount: 2_680, category: .shopping, date: date(monthOffset: 0, day: 19), note: "生活用品"),
            Transaction(amount: 900, category: .entertainment, date: now, note: "電影與聚餐")
        ]
        let historicalTotals: [(Int, Decimal, Decimal)] = [
            (-5, 54_000, 31_800), (-4, 55_000, 35_200), (-3, 55_000, 29_600),
            (-2, 57_000, 38_400), (-1, 57_000, 33_100)
        ]
        for (offset, income, expense) in historicalTotals {
            transactions.append(Transaction(amount: income, category: .salary,
                                            date: date(monthOffset: offset, day: 3), note: "薪資"))
            transactions.append(Transaction(amount: expense, category: .others,
                                            date: date(monthOffset: offset, day: 15), note: "當月支出彙整"))
        }
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
