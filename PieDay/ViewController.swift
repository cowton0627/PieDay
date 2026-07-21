import UIKit

final class ViewController: UIViewController {
    private let store = TransactionStore.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let incomeValue = UILabel()
    private let expenseValue = UILabel()
    private let availableValue = UILabel()
    private let budgetProgress = UIProgressView(progressViewStyle: .bar)
    private let budgetCaption = UILabel()
    private let budgetRows = UIStackView()
    private let donutChart = DonutChartView()
    private let insightLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "財務總覽"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "設定預算", style: .plain,
                                                            target: self, action: #selector(editBudgets))
        view.backgroundColor = .systemGroupedBackground
        buildLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
                                               name: TransactionStore.didChangeNotification, object: nil)
        refresh()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func buildLayout() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        let month = UILabel()
        month.text = Date.now.formatted(.dateTime.year().month(.wide)) + "現金流"
        month.font = .preferredFont(forTextStyle: .headline)
        month.textColor = .secondaryLabel
        contentStack.addArrangedSubview(month)

        let metrics = UIStackView(arrangedSubviews: [
            metricCard(title: "收入", value: incomeValue, color: .systemGreen),
            metricCard(title: "支出", value: expenseValue, color: .systemOrange),
            metricCard(title: "可用", value: availableValue, color: .systemIndigo)
        ])
        metrics.axis = .horizontal
        metrics.spacing = 10
        metrics.distribution = .fillEqually
        contentStack.addArrangedSubview(metrics)

        let budgetCard = card()
        let budgetTitle = sectionTitle("本月預算")
        budgetProgress.layer.cornerRadius = 4
        budgetProgress.clipsToBounds = true
        budgetCaption.font = .preferredFont(forTextStyle: .subheadline)
        budgetCaption.textColor = .secondaryLabel
        budgetCaption.numberOfLines = 0
        budgetRows.axis = .vertical
        budgetRows.spacing = 14
        let budgetStack = UIStackView(arrangedSubviews: [budgetTitle, budgetProgress, budgetCaption, budgetRows])
        budgetStack.axis = .vertical
        budgetStack.spacing = 12
        embed(budgetStack, in: budgetCard)
        contentStack.addArrangedSubview(budgetCard)

        let chartCard = card()
        let chartTitle = sectionTitle("支出去向")
        donutChart.translatesAutoresizingMaskIntoConstraints = false
        donutChart.heightAnchor.constraint(equalToConstant: 240).isActive = true
        let chartStack = UIStackView(arrangedSubviews: [chartTitle, donutChart])
        chartStack.axis = .vertical
        chartStack.spacing = 8
        embed(chartStack, in: chartCard)
        contentStack.addArrangedSubview(chartCard)

        let insightCard = card()
        insightLabel.font = .preferredFont(forTextStyle: .body)
        insightLabel.numberOfLines = 0
        insightLabel.textColor = .label
        let insightStack = UIStackView(arrangedSubviews: [sectionTitle("本月洞察"), insightLabel])
        insightStack.axis = .vertical
        insightStack.spacing = 10
        embed(insightStack, in: insightCard)
        contentStack.addArrangedSubview(insightCard)
    }

    private func metricCard(title: String, value: UILabel, color: UIColor) -> UIView {
        let card = self.card()
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        value.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        value.textColor = color
        value.adjustsFontSizeToFitWidth = true
        let stack = UIStackView(arrangedSubviews: [label, value])
        stack.axis = .vertical
        stack.spacing = 6
        embed(stack, in: card, inset: 12)
        return card
    }

    private func card() -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 18
        return view
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }

    private func embed(_ child: UIView, in parent: UIView, inset: CGFloat = 16) {
        parent.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset)
        ])
    }

    @objc private func refresh() {
        incomeValue.text = Money.string(store.monthlyIncome)
        expenseValue.text = Money.string(store.monthlyExpense)
        availableValue.text = Money.string(store.monthlyBalance)
        availableValue.textColor = store.monthlyBalance >= 0 ? .systemIndigo : .systemRed

        let budget = store.totalBudget
        let expense = store.monthlyExpense
        let progress = budget > 0 ? NSDecimalNumber(decimal: expense / budget).doubleValue : 0
        budgetProgress.progress = Float(min(progress, 1))
        budgetProgress.progressTintColor = progress > 1 ? .systemRed : progress >= 0.8 ? .systemOrange : .systemGreen
        budgetCaption.text = budget > 0
            ? "已使用 \(Money.string(expense))／\(Money.string(budget)) · \(Int(progress * 100))%"
            : "尚未設定預算。設定分類上限後，這裡會主動提示風險。"

        budgetRows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for category in TransactionCategory.expenseCases where store.budget(for: category) > 0 {
            budgetRows.addArrangedSubview(makeBudgetRow(category))
        }

        let breakdown = store.spendingBreakdown()
        donutChart.slices = breakdown.map {
            ChartSlice(value: CGFloat(NSDecimalNumber(decimal: $0.amount).doubleValue),
                       color: $0.category.color, label: $0.category.displayName)
        }
        donutChart.centerLabel.text = expense > 0 ? "本月支出\n\(Money.string(expense))" : "尚無\n支出"
        insightLabel.text = makeInsight(breakdown: breakdown, progress: progress)
    }

    private func makeBudgetRow(_ category: TransactionCategory) -> UIView {
        let spent = store.total(for: category)
        let budget = store.budget(for: category)
        let progress = store.budgetProgress(for: category)
        let title = UILabel()
        title.text = category.displayName
        title.font = .preferredFont(forTextStyle: .subheadline)
        let amount = UILabel()
        amount.text = "\(Money.string(spent)) / \(Money.string(budget))"
        amount.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        amount.textColor = progress > 1 ? .systemRed : .secondaryLabel
        let labels = UIStackView(arrangedSubviews: [title, UIView(), amount])
        labels.axis = .horizontal
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.progress = Float(min(progress, 1))
        bar.progressTintColor = progress > 1 ? .systemRed : progress >= 0.8 ? .systemOrange : category.color
        let stack = UIStackView(arrangedSubviews: [labels, bar])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeInsight(breakdown: [(category: TransactionCategory, amount: Decimal)], progress: Double) -> String {
        guard store.monthlyIncome > 0 || store.monthlyExpense > 0 else {
            return "載入展示資料或新增交易後，PieDay 會在這裡摘要你的消費狀況。"
        }
        var messages: [String] = []
        if store.monthlyBalance < 0 {
            messages.append("⚠️ 本月已超支 \(Money.string(-store.monthlyBalance))，建議先檢查非必要消費。")
        } else {
            messages.append("✓ 本月仍有 \(Money.string(store.monthlyBalance)) 可安排。")
        }
        if let top = breakdown.first {
            messages.append("最大支出是「\(top.category.displayName)」\(Money.string(top.amount))。")
        }
        if progress > 1 { messages.append("整體預算已超過 \(Int((progress - 1) * 100))%。") }
        else if progress >= 0.8 { messages.append("整體預算已使用八成，接下來的支出需要留意。") }
        return messages.joined(separator: "\n")
    }

    @objc private func editBudgets() { chooseBudgetCategory() }

    private func chooseBudgetCategory() {
        let sheet = UIAlertController(title: "設定分類預算", message: "選擇要調整的分類", preferredStyle: .actionSheet)
        for category in TransactionCategory.expenseCases {
            sheet.addAction(UIAlertAction(title: "\(category.displayName) · \(Money.string(store.budget(for: category)))", style: .default) { [weak self] _ in
                self?.promptBudget(for: category)
            })
        }
        sheet.addAction(UIAlertAction(title: "完成", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
    }

    private func promptBudget(for category: TransactionCategory) {
        let alert = UIAlertController(title: category.displayName + "預算", message: "輸入每月可支配上限", preferredStyle: .alert)
        alert.addTextField {
            $0.keyboardType = .decimalPad
            $0.placeholder = "金額"
            let current = self.store.budget(for: category)
            $0.text = current > 0 ? NSDecimalNumber(decimal: current).stringValue : nil
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "儲存", style: .default) { [weak self, weak alert] _ in
            guard let amount = Money.decimal(from: alert?.textFields?.first?.text), amount >= 0 else { return }
            self?.store.setBudget(amount, for: category)
        })
        present(alert, animated: true)
    }
}
