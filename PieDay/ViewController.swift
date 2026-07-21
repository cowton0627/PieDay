import UIKit

/// 預算 Dashboard：呈現 TransactionStore 各分類加總與比例圖。
/// Storyboard 上 customClass 仍是 "ViewController"，這個 scene 的 view 已清空成空白 root，整個 UI 由本檔 code 建構。
final class ViewController: UIViewController {

    // MARK: - Section: Summary（按分類顯示金額與佔比）
    private struct SummaryRow {
        let category: TransactionCategory
        let nameLabel = UILabel()
        let amountLabel = UILabel()
        let percentLabel = UILabel()
        let colorDot = UIView()
    }

    private var summaryRows: [TransactionCategory: SummaryRow] = [:]

    // MARK: - Subviews
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "月開支"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let summaryCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        return v
    }()

    private let summaryStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.alignment = .fill
        s.distribution = .equalSpacing
        s.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        s.isLayoutMarginsRelativeArrangement = true
        return s
    }()

    private let chartHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = "支出比例"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    private let chartContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let pieChartView = PieChartView()
    private let donutChartView = DonutChartView()

    private let pieButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("圓餅圖", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()

    private let donutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("環狀圖", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .secondarySystemFill
        b.tintColor = .label
        b.setTitleColor(.label, for: .normal)
        b.layer.cornerRadius = 12
        return b
    }()

    private let buttonRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.distribution = .fillEqually
        return s
    }()

    private let rootStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.alignment = .fill
        return s
    }()

    // MARK: - Private
    private let store = TransactionStore.shared
    private enum ChartMode { case none, pie, donut }
    private var currentMode: ChartMode = .none

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        buildLayout()
        wireActions()
        observeStoreChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromStore()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout
    private func buildLayout() {
        buildSummaryRows()

        view.addSubview(rootStack)
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(summaryStack)
        summaryStack.translatesAutoresizingMaskIntoConstraints = false

        chartContainer.addSubview(pieChartView)
        chartContainer.addSubview(donutChartView)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        donutChartView.translatesAutoresizingMaskIntoConstraints = false
        pieChartView.isHidden = true
        donutChartView.isHidden = true

        buttonRow.addArrangedSubview(pieButton)
        buttonRow.addArrangedSubview(donutButton)

        rootStack.addArrangedSubview(titleLabel)
        rootStack.addArrangedSubview(summaryCard)
        rootStack.addArrangedSubview(chartHeaderLabel)
        rootStack.addArrangedSubview(chartContainer)
        rootStack.addArrangedSubview(buttonRow)

        // Root stack 填滿 safeArea + padding
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            summaryStack.topAnchor.constraint(equalTo: summaryCard.topAnchor),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor),

            // 按鈕高度
            pieButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        // Chart 在 container 內居中 + 保持 1:1 + 最多占 container 85%（Pie 圓本身只佔 view 62%，外圍留給 leader line + label）
        let chartFitRatio: CGFloat = 0.85
        for chart in [pieChartView, donutChartView] as [UIView] {
            NSLayoutConstraint.activate([
                chart.centerXAnchor.constraint(equalTo: chartContainer.centerXAnchor),
                chart.centerYAnchor.constraint(equalTo: chartContainer.centerYAnchor),
                chart.widthAnchor.constraint(equalTo: chart.heightAnchor),
                chart.widthAnchor.constraint(lessThanOrEqualTo: chartContainer.widthAnchor, multiplier: chartFitRatio),
                chart.heightAnchor.constraint(lessThanOrEqualTo: chartContainer.heightAnchor, multiplier: chartFitRatio),
            ])
            let widthFill = chart.widthAnchor.constraint(equalTo: chartContainer.widthAnchor, multiplier: chartFitRatio)
            let heightFill = chart.heightAnchor.constraint(equalTo: chartContainer.heightAnchor, multiplier: chartFitRatio)
            widthFill.priority = .defaultHigh
            heightFill.priority = .defaultHigh
            widthFill.isActive = true
            heightFill.isActive = true
        }

        // 讓 chart container 吃掉所有剩餘垂直空間
        chartContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
        chartContainer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        summaryCard.setContentHuggingPriority(.required, for: .vertical)
        chartHeaderLabel.setContentHuggingPriority(.required, for: .vertical)
        buttonRow.setContentHuggingPriority(.required, for: .vertical)
    }

    private func buildSummaryRows() {
        for category in TransactionCategory.allCases {
            let row = SummaryRow(category: category)

            row.colorDot.backgroundColor = category.color
            row.colorDot.layer.cornerRadius = 6
            row.colorDot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                row.colorDot.widthAnchor.constraint(equalToConstant: 12),
                row.colorDot.heightAnchor.constraint(equalToConstant: 12),
            ])

            row.nameLabel.text = category.displayName
            row.nameLabel.font = .systemFont(ofSize: 17, weight: .medium)

            row.amountLabel.text = "0"
            row.amountLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
            row.amountLabel.textAlignment = .right
            row.amountLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            row.percentLabel.text = "0.0%"
            row.percentLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
            row.percentLabel.textColor = .secondaryLabel
            row.percentLabel.textAlignment = .right
            row.percentLabel.setContentHuggingPriority(.required, for: .horizontal)
            row.percentLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true

            // 收入分類（薪水）不顯示百分比
            row.percentLabel.isHidden = category.isIncome

            let rowStack = UIStackView(arrangedSubviews: [
                row.colorDot, row.nameLabel, row.amountLabel, row.percentLabel
            ])
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.alignment = .center

            summaryStack.addArrangedSubview(rowStack)
            summaryRows[category] = row
        }
    }

    private func wireActions() {
        pieButton.addTarget(self, action: #selector(pieTapped), for: .touchUpInside)
        donutButton.addTarget(self, action: #selector(donutTapped), for: .touchUpInside)
    }

    private func observeStoreChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: TransactionStore.didChangeNotification,
            object: nil
        )
    }

    // MARK: - Display
    @objc private func storeDidChange() {
        refreshFromStore()
        switch currentMode {
        case .pie:   showChart(mode: .pie, animated: false)
        case .donut: showChart(mode: .donut, animated: false)
        case .none:  break
        }
    }

    private func refreshFromStore() {
        let salary = store.total(for: .salary)
        for (category, row) in summaryRows {
            let amount = store.total(for: category)
            row.amountLabel.text = String(format: "%.0f", amount)
            if !category.isIncome {
                row.percentLabel.text = salary > 0
                    ? String(format: "%.1f%%", amount / salary * 100)
                    : "—"
            }
        }
    }

    private func currentSlices() -> [ChartSlice] {
        store.expenseRatiosAgainstSalary().map { entry in
            let color = entry.category?.color ?? .systemGray
            let label = entry.category?.displayName ?? "剩餘"
            return ChartSlice(value: CGFloat(entry.ratio), color: color, label: label)
        }
    }

    private func showChart(mode: ChartMode, animated: Bool) {
        let slices = currentSlices()
        guard !slices.isEmpty else {
            showEmptyDataAlert()
            return
        }
        currentMode = mode

        pieChartView.slices = slices
        donutChartView.slices = slices
        donutChartView.centerLabel.text = donutCenterText()

        let apply: () -> Void = {
            self.pieChartView.isHidden = (mode != .pie)
            self.donutChartView.isHidden = (mode != .donut)
        }

        if animated {
            UIView.transition(with: chartContainer,
                              duration: 0.25,
                              options: [.transitionCrossDissolve],
                              animations: apply)
        } else {
            apply()
        }
    }

    private func donutCenterText() -> String {
        let remaining = store.total(for: .salary)
            - store.total(for: .food)
            - store.total(for: .loan)
            - store.total(for: .others)
        return String(format: "結餘\n%.0f", remaining)
    }

    private func showEmptyDataAlert() {
        let alert = UIAlertController(
            title: "尚無資料",
            message: "請先到 Transaction 分頁新增「薪水」收入與支出項目，再回來查看比例。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func pieTapped() {
        showChart(mode: .pie, animated: true)
    }

    @objc private func donutTapped() {
        showChart(mode: .donut, animated: true)
    }
}
