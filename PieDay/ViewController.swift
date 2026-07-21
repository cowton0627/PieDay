import UIKit

final class ViewController: UIViewController {
    private let store = TransactionStore.shared
    private let calendar = Calendar.current
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let monthTitle = UILabel()
    private let nextMonthButton = UIButton(type: .system)
    private let incomeValue = UILabel()
    private let expenseValue = UILabel()
    private let availableValue = UILabel()
    private let budgetProgress = UIProgressView(progressViewStyle: .bar)
    private let budgetCaption = UILabel()
    private let budgetRows = UIStackView()
    private let donutChart = DonutChartView()
    private let trendChart = MonthlyTrendView()
    private let insightLabel = UILabel()
    private var selectedMonth = Date()

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

        monthTitle.font = .preferredFont(forTextStyle: .headline)
        monthTitle.textColor = .label
        monthTitle.textAlignment = .center
        monthTitle.setContentCompressionResistancePriority(.required, for: .horizontal)
        let previous = UIButton(type: .system)
        previous.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previous.accessibilityLabel = "上一個月"
        previous.addTarget(self, action: #selector(showPreviousMonth), for: .touchUpInside)
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextMonthButton.accessibilityLabel = "下一個月"
        nextMonthButton.addTarget(self, action: #selector(showNextMonth), for: .touchUpInside)
        let monthSelector = UIStackView(arrangedSubviews: [previous, UIView(), monthTitle, UIView(), nextMonthButton])
        monthSelector.axis = .horizontal
        monthSelector.alignment = .center
        contentStack.addArrangedSubview(monthSelector)

        let currentMonthButton = UIButton(type: .system)
        currentMonthButton.setTitle("回到本月", for: .normal)
        currentMonthButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        currentMonthButton.addTarget(self, action: #selector(showCurrentMonth), for: .touchUpInside)
        contentStack.addArrangedSubview(currentMonthButton)

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

        let trendCard = card()
        trendChart.translatesAutoresizingMaskIntoConstraints = false
        trendChart.heightAnchor.constraint(equalToConstant: 210).isActive = true
        let trendStack = UIStackView(arrangedSubviews: [sectionTitle("近六個月趨勢"), trendChart])
        trendStack.axis = .vertical
        trendStack.spacing = 12
        embed(trendStack, in: trendCard)
        contentStack.addArrangedSubview(trendCard)

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
        monthTitle.text = selectedMonth.formatted(.dateTime.year().month(.wide)) + "現金流"
        nextMonthButton.isEnabled = !calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
        let income = store.total(type: .income, in: selectedMonth)
        let expense = store.total(type: .expense, in: selectedMonth)
        let balance = income - expense
        incomeValue.text = Money.string(income)
        expenseValue.text = Money.string(expense)
        availableValue.text = Money.string(balance)
        availableValue.textColor = balance >= 0 ? .systemIndigo : .systemRed

        let budget = store.totalBudget
        let progress = budget > 0 ? NSDecimalNumber(decimal: expense / budget).doubleValue : 0
        budgetProgress.progress = Float(min(progress, 1))
        budgetProgress.progressTintColor = progress > 1 ? .systemRed : progress >= 0.8 ? .systemOrange : .systemGreen
        budgetCaption.text = budget > 0
            ? "已使用 \(Money.string(expense))／\(Money.string(budget)) · \(Int(progress * 100))%"
            : "尚未設定預算。設定分類上限後，這裡會主動提示風險。"

        budgetRows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for category in TransactionCategory.expenseCases where store.budget(for: category) > 0 {
            budgetRows.addArrangedSubview(makeBudgetRow(category, month: selectedMonth))
        }

        let breakdown = store.spendingBreakdown(in: selectedMonth)
        donutChart.slices = breakdown.map {
            ChartSlice(value: CGFloat(NSDecimalNumber(decimal: $0.amount).doubleValue),
                       color: $0.category.color, label: $0.category.displayName)
        }
        donutChart.centerLabel.text = expense > 0 ? "當月支出\n\(Money.string(expense))" : "尚無\n支出"
        trendChart.summaries = store.monthlySummaries(endingAt: selectedMonth)
        insightLabel.text = makeInsight(income: income, expense: expense, balance: balance,
                                        breakdown: breakdown, progress: progress)
    }

    private func makeBudgetRow(_ category: TransactionCategory, month: Date) -> UIView {
        let spent = store.total(for: category, in: month)
        let budget = store.budget(for: category)
        let progress = store.budgetProgress(for: category, in: month)
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

    private func makeInsight(income: Decimal, expense: Decimal, balance: Decimal,
                             breakdown: [(category: TransactionCategory, amount: Decimal)], progress: Double) -> String {
        guard income > 0 || expense > 0 else {
            return "這個月份尚無交易，切換月份或新增交易後即可查看摘要。"
        }
        var messages: [String] = []
        if balance < 0 {
            messages.append("⚠️ 當月已超支 \(Money.string(-balance))，建議先檢查非必要消費。")
        } else {
            messages.append("✓ 當月仍有 \(Money.string(balance)) 可安排。")
        }
        if let top = breakdown.first {
            messages.append("最大支出是「\(top.category.displayName)」\(Money.string(top.amount))。")
        }
        if progress > 1 { messages.append("整體預算已超過 \(Int((progress - 1) * 100))%。") }
        else if progress >= 0.8 { messages.append("整體預算已使用八成，接下來的支出需要留意。") }
        return messages.joined(separator: "\n")
    }

    @objc private func showPreviousMonth() { moveMonth(by: -1) }

    @objc private func showNextMonth() {
        guard !calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month) else { return }
        moveMonth(by: 1)
    }

    @objc private func showCurrentMonth() {
        selectedMonth = Date()
        refresh()
    }

    private func moveMonth(by offset: Int) {
        guard let month = calendar.date(byAdding: .month, value: offset, to: selectedMonth) else { return }
        selectedMonth = month
        refresh()
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

private final class MonthlyTrendView: UIView {
    var summaries: [TransactionStore.MonthlySummary] = [] { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        accessibilityLabel = "近六個月收入與支出趨勢"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !summaries.isEmpty else { return }
        let labelHeight: CGFloat = 24
        let legendHeight: CGFloat = 22
        let chartRect = bounds.insetBy(dx: 8, dy: 0)
            .inset(by: UIEdgeInsets(top: legendHeight, left: 0, bottom: labelHeight, right: 0))
        let maximum = summaries.flatMap { [$0.income, $0.expense] }
            .map { NSDecimalNumber(decimal: $0).doubleValue }.max() ?? 0
        let scaleMaximum = max(maximum, 1)
        let groupWidth = chartRect.width / CGFloat(summaries.count)
        let barWidth = min(13, groupWidth * 0.28)

        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(1 / UIScreen.main.scale)
        context.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        context.strokePath()

        for (index, summary) in summaries.enumerated() {
            let centerX = chartRect.minX + groupWidth * (CGFloat(index) + 0.5)
            drawBar(value: summary.income, maximum: scaleMaximum,
                    rect: chartRect, x: centerX - barWidth - 1, width: barWidth, color: .systemGreen)
            drawBar(value: summary.expense, maximum: scaleMaximum,
                    rect: chartRect, x: centerX + 1, width: barWidth, color: .systemOrange)
            let label = summary.month.formatted(.dateTime.month(.abbreviated)) as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.secondaryLabel
            ]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: centerX - size.width / 2, y: chartRect.maxY + 6), withAttributes: attributes)
        }
        drawLegend(in: rect)
    }

    private func drawBar(value: Decimal, maximum: Double, rect: CGRect,
                         x: CGFloat, width: CGFloat, color: UIColor) {
        let ratio = CGFloat(NSDecimalNumber(decimal: value).doubleValue / maximum)
        let height = rect.height * ratio
        let path = UIBezierPath(roundedRect: CGRect(x: x, y: rect.maxY - height, width: width, height: height),
                                cornerRadius: min(4, width / 2))
        color.setFill()
        path.fill()
    }

    private func drawLegend(in rect: CGRect) {
        let text = "● 收入    ● 支出"
        let attributed = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.secondaryLabel
        ])
        attributed.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: 0, length: 1))
        attributed.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: NSRange(location: 8, length: 1))
        attributed.draw(at: CGPoint(x: rect.midX - attributed.size().width / 2, y: 0))
    }
}
