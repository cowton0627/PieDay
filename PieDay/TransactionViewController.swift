import UIKit

final class TransactionViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var addTransactionButton: UIButton!

    // MARK: - Private
    private let store = TransactionStore.shared
    private let cellIdentifier = "TransactionCell"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        transactionTableView.dataSource = self
        transactionTableView.delegate = self
        transactionTableView.rowHeight = UITableView.automaticDimension
        transactionTableView.estimatedRowHeight = 52
        transactionTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        transactionAmountTextField.delegate = self
        styleControls()
        refreshBalance()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: TransactionStore.didChangeNotification,
            object: nil
        )
    }

    private func styleControls() {
        // Segmented control 字體用 HIG 推薦的 14 medium
        let segFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        transactionTypeSegmentedControl.setTitleTextAttributes([.font: segFont], for: .normal)
        transactionTypeSegmentedControl.setTitleTextAttributes([.font: segFont], for: .selected)

        // 「新增」按鈕：全寬精緻按鈕（leading/trailing 對齊 safe area + margin）
        addTransactionButton.setTitle("新增", for: .normal)
        addTransactionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addTransactionButton.setTitleColor(.white, for: .normal)
        addTransactionButton.backgroundColor = .systemBlue
        addTransactionButton.layer.cornerRadius = 12
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addTransactionButton.heightAnchor.constraint(equalToConstant: 50),
            addTransactionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            addTransactionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])

        // 餘額數字顏色用 secondary 取代亮色（亮色由 balance 正負決定）
        balanceLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func storeDidChange() {
        refreshBalance()
        transactionTableView.reloadData()
    }

    // MARK: - Display
    private func refreshBalance() {
        let balance = store.balance
        balanceLabel.text = String(format: "%.0f", balance)
        balanceLabel.textColor = balance >= 0 ? .label : .systemRed
    }

    // MARK: - IBAction
    @IBAction func addTransactionPressed(_ sender: UIButton) {
        guard let amount = parseAmount() else {
            showAlert(title: "金額無效", message: "請輸入大於 0 的金額")
            return
        }
        view.endEditing(true)

        if transactionTypeSegmentedControl.selectedSegmentIndex == 0 {
            // Expense — 讓使用者挑分類
            promptExpenseCategory { [weak self] category in
                guard let self else { return }
                self.store.add(Transaction(amount: amount, category: category))
                self.transactionAmountTextField.text = nil
            }
        } else {
            // Income — 視為薪水
            store.add(Transaction(amount: amount, category: .salary))
            transactionAmountTextField.text = nil
        }
    }

    // MARK: - Helpers
    private func parseAmount() -> Double? {
        guard let text = transactionAmountTextField.text,
              let value = Double(text),
              value > 0 else { return nil }
        return value
    }

    private func promptExpenseCategory(_ completion: @escaping (TransactionCategory) -> Void) {
        let sheet = UIAlertController(title: "選擇分類", message: nil, preferredStyle: .actionSheet)
        for category in TransactionCategory.allCases where !category.isIncome {
            sheet.addAction(UIAlertAction(title: category.displayName, style: .default) { _ in
                completion(category)
            })
        }
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(sheet, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TransactionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let transaction = store.transactions[indexPath.row]
        let sign = transaction.type == .income ? "+" : "-"
        cell.textLabel?.text = String(
            format: "%@%.2f  %@  %@",
            sign,
            transaction.amount,
            transaction.category.displayName,
            dateFormatter.string(from: transaction.date)
        )
        cell.textLabel?.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.textColor = transaction.type == .income ? .systemGreen : .systemOrange
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        store.delete(at: indexPath.row)
    }
}

// MARK: - UITextFieldDelegate
extension TransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        return string.rangeOfCharacter(from: allowed.inverted) == nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
