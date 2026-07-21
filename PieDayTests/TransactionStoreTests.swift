import XCTest
@testable import PieDay

final class TransactionStoreTests: XCTestCase {
    private let suiteName = "PieDay.TransactionStoreTests"
    private var defaults: UserDefaults!
    private var store: TransactionStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        store = TransactionStore(defaults: defaults, calendar: Calendar(identifier: .gregorian))
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
        super.tearDown()
    }

    func testBalanceUsesDecimalIncomeAndExpense() {
        store.add(Transaction(amount: Decimal(string: "100.10")!, category: .salary))
        store.add(Transaction(amount: Decimal(string: "30.05")!, category: .food))
        XCTAssertEqual(store.balance, Decimal(string: "70.05"))
    }

    func testMonthlyTotalsExcludeOtherMonths() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        store.add(Transaction(amount: 500, category: .food, date: now))
        store.add(Transaction(amount: 900, category: .food, date: previousMonth))
        XCTAssertEqual(store.total(for: .food, in: now), 500)
    }

    func testUpdateAndDeleteUseStableIdentity() {
        let original = Transaction(amount: 100, category: .food, note: "午餐")
        store.add(original)
        store.update(Transaction(id: original.id, amount: 120, category: .food, note: "午餐"))
        XCTAssertEqual(store.transactions.first?.amount, 120)
        store.delete(id: original.id)
        XCTAssertTrue(store.transactions.isEmpty)
    }

    func testBudgetProgressCanRepresentOverspending() {
        store.setBudget(1_000, for: .food)
        store.add(Transaction(amount: 1_250, category: .food))
        XCTAssertEqual(store.budgetProgress(for: .food), 1.25, accuracy: 0.001)
    }

    func testMonthlySummariesAreChronologicalAndIncludeEmptyMonths() {
        let calendar = Calendar(identifier: .gregorian)
        let end = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        let may = calendar.date(from: DateComponents(year: 2026, month: 5, day: 10))!
        store.add(Transaction(amount: 2_000, category: .salary, date: may))
        store.add(Transaction(amount: 700, category: .food, date: end))

        let summaries = store.monthlySummaries(endingAt: end, count: 3)

        XCTAssertEqual(summaries.map { calendar.component(.month, from: $0.month) }, [5, 6, 7])
        XCTAssertEqual(summaries.map(\.income), [2_000, 0, 0])
        XCTAssertEqual(summaries.map(\.expense), [0, 0, 700])
    }

    func testBreakdownAndBudgetProgressUseSelectedMonth() {
        let calendar = Calendar(identifier: .gregorian)
        let current = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        let previous = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        store.setBudget(1_000, for: .food)
        store.add(Transaction(amount: 800, category: .food, date: previous))
        store.add(Transaction(amount: 200, category: .food, date: current))

        XCTAssertEqual(store.budgetProgress(for: .food, in: previous), 0.8, accuracy: 0.001)
        XCTAssertEqual(store.spendingBreakdown(in: previous).first?.amount, 800)
    }

    func testPersistsTransactionsAndBudgets() {
        store.add(Transaction(amount: 88, category: .transport))
        store.setBudget(2_000, for: .transport)
        let restored = TransactionStore(defaults: defaults, calendar: Calendar(identifier: .gregorian))
        XCTAssertEqual(restored.transactions.first?.amount, 88)
        XCTAssertEqual(restored.budget(for: .transport), 2_000)
    }
}
