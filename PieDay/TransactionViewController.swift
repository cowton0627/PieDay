import UIKit

final class TransactionViewController: UIViewController {
    private let store = TransactionStore.shared
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private let balanceLabel = UILabel()
    private let monthLabel = UILabel()
    private var query = ""

    private var visibleTransactions: [Transaction] {
        let monthly = store.transactions(in: Date()).sorted { $0.date > $1.date }
        guard !query.isEmpty else { return monthly }
        return monthly.filter {
            $0.category.displayName.localizedCaseInsensitiveContains(query) ||
            ($0.note?.localizedCaseInsensitiveContains(query) ?? false) ||
            Money.string($0.amount).localizedCaseInsensitiveContains(query)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "本月交易"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        addButton.accessibilityLabel = "新增交易"
        addButton.accessibilityIdentifier = "addTransaction"
        let dataButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: dataMenu)
        dataButton.accessibilityLabel = "資料選單"
        dataButton.accessibilityIdentifier = "dataMenu"
        navigationItem.rightBarButtonItems = [addButton, dataButton]

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜尋分類、備註或金額"
        searchController.searchBar.accessibilityIdentifier = "transactionSearch"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        configureHeader()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Transaction")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(storeDidChange),
                                               name: TransactionStore.didChangeNotification, object: nil)
        refresh()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private var dataMenu: UIMenu {
        UIMenu(children: [
            UIAction(title: "載入展示資料", image: UIImage(systemName: "sparkles")) { [weak self] _ in
                self?.confirmDemoData()
            },
            UIAction(title: "清除所有資料", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.confirmRemoveAll()
            }
        ])
    }

    private func configureHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 112))
        monthLabel.text = Date.now.formatted(.dateTime.year().month(.wide))
        monthLabel.font = .preferredFont(forTextStyle: .subheadline)
        monthLabel.adjustsFontForContentSizeCategory = true
        monthLabel.textColor = .secondaryLabel
        balanceLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(
            for: .monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        )
        balanceLabel.adjustsFontForContentSizeCategory = true
        balanceLabel.numberOfLines = 0
        balanceLabel.accessibilityIdentifier = "totalBalance"
        let caption = UILabel()
        caption.text = "目前總資產"
        caption.font = .preferredFont(forTextStyle: .subheadline)
        caption.adjustsFontForContentSizeCategory = true
        caption.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [monthLabel, caption, balanceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        header.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        tableView.tableHeaderView = header
    }

    @objc private func storeDidChange() { refresh() }

    private func refresh() {
        balanceLabel.text = Money.string(store.balance)
        balanceLabel.textColor = store.balance >= 0 ? .label : .systemRed
        balanceLabel.accessibilityLabel = "目前總資產"
        balanceLabel.accessibilityValue = balanceLabel.text
        tableView.reloadData()
        tableView.backgroundView = visibleTransactions.isEmpty ? emptyStateView() : nil
    }

    private func emptyStateView() -> UIView {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = query.isEmpty ? "emptyTransactions" : "emptySearchResults"
        label.text = query.isEmpty
            ? "本月還沒有交易\n\n點右上角 ＋，幾秒內完成第一筆記帳。"
            : "找不到相符交易\n\n試試其他分類或備註。"
        return label
    }

    @objc private func addTapped() { chooseCategory(for: nil) }

    private func chooseCategory(for transaction: Transaction?) {
        let sheet = UIAlertController(title: transaction == nil ? "新增交易" : "編輯交易",
                                      message: "先選擇收支分類", preferredStyle: .actionSheet)
        for category in TransactionCategory.allCases {
            let prefix = category.isIncome ? "收入 · " : "支出 · "
            sheet.addAction(UIAlertAction(title: prefix + category.displayName, style: .default) { [weak self] _ in
                self?.showEditor(transaction: transaction, category: category)
            })
        }
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
    }

    private func showEditor(transaction: Transaction?, category: TransactionCategory) {
        let alert = UIAlertController(title: category.displayName,
                                      message: category.isIncome ? "記錄本月收入" : "記錄本月支出",
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "金額"
            $0.keyboardType = .decimalPad
            $0.text = transaction.map { NSDecimalNumber(decimal: $0.amount).stringValue }
        }
        alert.addTextField {
            $0.placeholder = "備註（選填）"
            $0.text = transaction?.note
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "儲存", style: .default) { [weak self, weak alert] _ in
            guard let self, let amount = Money.decimal(from: alert?.textFields?.first?.text), amount > 0 else {
                self?.showInvalidAmount()
                return
            }
            let note = alert?.textFields?.last?.text
            if let old = transaction {
                self.store.update(Transaction(id: old.id, amount: amount, category: category,
                                              date: old.date, note: note))
            } else {
                self.store.add(Transaction(amount: amount, category: category, note: note))
            }
        })
        present(alert, animated: true)
    }

    private func showInvalidAmount() {
        let alert = UIAlertController(title: "金額無效", message: "請輸入大於 0 的金額。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }

    private func confirmDemoData() {
        let alert = UIAlertController(title: "載入展示資料？", message: "目前資料將替換成一組完整的本月收支與預算。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "載入", style: .default) { [weak self] _ in self?.store.loadDemoData() })
        present(alert, animated: true)
    }

    private func confirmRemoveAll() {
        let alert = UIAlertController(title: "清除所有資料？", message: "此動作無法復原。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清除", style: .destructive) { [weak self] _ in self?.store.removeAll() })
        present(alert, animated: true)
    }
}

extension TransactionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visibleTransactions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = visibleTransactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: transaction.category.symbolName)
        content.imageProperties.tintColor = transaction.category.color
        content.text = transaction.note ?? transaction.category.displayName
        content.secondaryText = "\(transaction.category.displayName) · \(transaction.date.formatted(date: .abbreviated, time: .omitted))"
        content.textProperties.font = .preferredFont(forTextStyle: .body)
        cell.contentConfiguration = content
        let amount = UILabel()
        amount.text = (transaction.type == .income ? "+" : "−") + Money.string(transaction.amount)
        amount.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        )
        amount.adjustsFontForContentSizeCategory = true
        amount.adjustsFontSizeToFitWidth = true
        amount.textColor = transaction.type == .income ? .systemGreen : .label
        cell.accessoryView = amount
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "transactionRow"
        cell.accessibilityLabel = [
            transaction.note ?? transaction.category.displayName,
            transaction.category.displayName,
            transaction.date.formatted(date: .long, time: .omitted),
            transaction.type == .income ? "收入" : "支出",
            Money.string(transaction.amount)
        ].joined(separator: "，")
        cell.accessibilityHint = "點兩下可編輯交易"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        chooseCategory(for: visibleTransactions[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let transaction = visibleTransactions[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "刪除") { [weak self] _, _, done in
            self?.store.delete(id: transaction.id)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension TransactionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        refresh()
    }
}
