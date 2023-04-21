//
//  TransactionViewController.swift
//  Demo_018
//
//  Created by Chun-Li Cheng on 2023/4/21.
//

import UIKit

//var firstPageBalance: Double = 0

class TransactionViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transactionTableView: UITableView!
    
    // MARK: - Private Properties
    private let identifier = "TransactionCell"
    private let incomeText = "Income"
    private let expenseText = "Expense"
    
    private var transactions: [Transaction] = []
    private var balance: Double = 0.0 {
        didSet {
            balanceLabel.text = String(format: "%.2f", balance)
            balanceLabel.textColor = balance >= 0 ? .systemGreen : .systemRed
            passDataToDestination()
        }
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        balanceLabel.text = "..."
        view.backgroundColor = .systemGray6
        transactionTableView.dataSource = self
        transactionAmountTextField.delegate = self
    }
    // MARK: - Private Functions
    private func passDataToDestination() {
        guard let tabBarController = self.tabBarController,
              let viewControllers = tabBarController.viewControllers else { return }

        for viewController in viewControllers {
            if let navigationController = viewController as? UINavigationController,
               let vc = navigationController.viewControllers.first as? ViewController {
                vc.sharedData = balance
            } else if let vc = viewController as? ViewController {
                vc.sharedData = balance
            }
        }
    }
    // MARK: - IBOutlet
    @IBAction func addTransactionPressed(_ sender: UIButton) {
        guard let amountText = transactionAmountTextField.text,
              let amount = Double(amountText) else { return }
        let type: TransactionType = transactionTypeSegmentedControl.selectedSegmentIndex == 0 ? .expense : .income
        let transaction = Transaction(amount: amount, type: type)
        transactions.append(transaction)
        balance += type == .income ? amount : -amount
        transactionTableView.reloadData()
        transactionAmountTextField.text = nil
    }
}
// MARK: - UITableViewDataSource
extension TransactionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        let transaction = transactions[indexPath.row]
        cell.textLabel?.text = String(format: "%.2f %@",
                                      transaction.amount,
                                      transaction.type == .income ? incomeText : expenseText)
        cell.textLabel?.textColor = transaction.type == .income ? .systemGreen : .systemRed
        return cell
    }
}
// MARK: - UITextFieldDelegate
extension TransactionViewController: UITextFieldDelegate {
    // 保證使用者輸入數字或小數點
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}

struct Transaction {
    let amount: Double
    let type: TransactionType
}

enum TransactionType {
    case expense
    case income
}
