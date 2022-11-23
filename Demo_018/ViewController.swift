//
//  ViewController.swift
//  Demo_018
//
//  Created by 鄭淳澧 on 2021/7/30.
//

import UIKit
import SwiftUI

// VC 開一個接口傳值
//protocol ViewControllerDelegate: AnyObject {
//    func receiveData(data: String)
//}

//MARK: 月開支表，首頁
class ViewController: UIViewController {

//    weak var delegate: ViewControllerDelegate?
    
    //MARK: - IBOutlet
    // 輸入框
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var eatTextField: UITextField!
    @IBOutlet weak var loanTextField: UITextField!
    @IBOutlet weak var othersTextField: UITextField!
    // 顯示百分佔比
    @IBOutlet weak var eatPrecentageLabel: UILabel!
    @IBOutlet weak var loanPrecentageLabel: UILabel!
    @IBOutlet weak var othersPrecentageLabel: UILabel!
    //MARK: - Properties
    // 百分佔比
//    var eatSalaryRatio: Double = 0
//    var loanSalaryRatio: Double = 0
//    var othersSalaryRatio: Double = 0
//    var lastRatio: Double = 0
//    var result: Double = 0
    
    // 繪圖所需百分佔比
    var percentages: [CGFloat] = []

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardReturn()
        
        let pathView = UIView(frame: view.frame)
        pathView.backgroundColor = .red
        
        //試畫三角路徑
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 100, y: 100))
//        path.addLine(to: CGPoint(x: 200, y: 100))
//        path.addLine(to: CGPoint(x: 200, y: 200))
//        path.close()
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        pathView.layer.mask = shapeLayer
//
//        view.addSubview(pathView)
        
        //試畫圓餅路徑1
//        let aDegree = CGFloat.pi
//
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 200, y: 450))
//        path.addArc(withCenter: CGPoint(x: 200, y: 450),
//                    radius: 100,
//                    startAngle: aDegree * 0,
//                    endAngle: aDegree * 2, clockwise: true)
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        pathView.layer.mask = shapeLayer
//
//        view.addSubview(pathView)
        
        //試畫圓餅路徑2（其實是換一個方式畫三角）
//        let aDegree = CGFloat.pi
//        let path = UIBezierPath(arcCenter: CGPoint(x: 250, y: 500),
//                                radius: 0,
//                                startAngle: aDegree * 0,
//                                endAngle: aDegree * 0, clockwise: true)
//        path.addLine(to: CGPoint(x: 150, y: 500))
//        path.addArc(withCenter: CGPoint(x: 200, y: 400),
//                    radius: 0,
//                    startAngle: aDegree * 0,
//                    endAngle: aDegree * 0, clockwise: true)
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        pathView.layer.mask = shapeLayer
//
//        view.addSubview(pathView)
        
        //試畫圓環路徑1
//        let lineWidth: CGFloat = 150
//        let radius: CGFloat = 50
//
//        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth,
//                                                     y: lineWidth,
//                                                     width: radius * 2,
//                                                     height: radius * 2))
//
//        let circleLayer = CAShapeLayer()
//        circleLayer.path = circlePath.cgPath
//
//        circleLayer.strokeColor = UIColor.systemGray6.cgColor
//        circleLayer.lineWidth = 5
//        circleLayer.fillColor = UIColor.clear.cgColor
//
//        pathView.layer.mask = circleLayer
//
//        view.addSubview(pathView)
        
        
    }
    
    // 首頁不顯示 Navigation Bar，但螢幕反應時間會看到上方閃過黑條
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    

    //MARK: - IBAction
    @IBAction func resultBtnPressed(_ sender: UIButton) {
//        UserDefaults.setValue(result, forKey: "monthDeposit")

        if let salary = Double(salaryTextField.text ?? "0"),
            let eat =  Double(eatTextField.text ?? "0"),
            let loan = Double(loanTextField.text ?? "0"),
            let others = Double(othersTextField.text ?? "0") {
            
            let result = salary - eat - loan - others
            percentages.append(salaryRatio(something: eat, salary: salary))
            percentages.append(salaryRatio(something: loan, salary: salary))
            percentages.append(salaryRatio(something: others, salary: salary))
            percentages.append(salaryRatio(something: result, salary: salary))
//            eatSalaryRatio = eat / salary * 100
//            loanSalaryRatio = loan / salary * 100
//            othersSalaryRatio = others / salary * 100
//            lastRatio = result / salary * 100
//
//            percentages.append(CGFloat(eatSalaryRatio))
//            percentages.append(CGFloat(loanSalaryRatio))
//            percentages.append(CGFloat(othersSalaryRatio))
//            percentages.append(CGFloat(lastRatio))
            drawing()
//            delegate?.receiveData(data: String(result))
            
            if let depositVC = self.tabBarController?.viewControllers?[1] as? DepositViewController {
                depositVC.depositLabel.text = "\(result)"
            }
            
        } else {
            // 若有欄位空則出現 Alert
            let alertController = UIAlertController(title: "Caution",
                                                    message: "Don't leave any blank",
                                                    preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back",
                                            style: .cancel,
                                            handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }
                
    }
    
    @IBAction func salaryEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0") {
            
            if let eat = Double(eatTextField.text ?? "0") {
                eatPrecentageLabel.text = String(format: "%.1f",
                                                 eat / salary * 100) + "%"
            } else { eatPrecentageLabel.text = "0.0%" }
            
            if let loan = Double(loanTextField.text ?? "0") {
                loanPrecentageLabel.text = String(format: "%.1f",
                                                  loan / salary * 100) + "%"
            } else { loanPrecentageLabel.text = "0.0%" }
            
            if let others = Double(othersTextField.text ?? "0") {
                othersPrecentageLabel.text = String(format: "%.1f",
                                                    others / salary * 100) + "%"
            } else { othersPrecentageLabel.text = "0.0%" }
            
        }
        
//        if let salary = Double(salaryTextField.text ?? "0"),
//            let eat = Double(eatTextField.text ?? "0") {
////            eatSalaryRatio = eat / salary * 100
//            eatPrecentageLabel.text = String(format: "%.1f",
//                                             eat / salary * 100) + "%"
//            print("\(salary)")
//
//        } else {
//            eatPrecentageLabel.text = "0.0%"
//        }
        
//        if let salary = Double(salaryTextField.text ?? "0"),
//            let loan = Double(loanTextField.text ?? "0") {
////            loanSalaryRatio = loan / salary * 100
//            loanPrecentageLabel.text = String(format: "%.1f",
//                                              loan / salary * 100) + "%"
//        } else {
//            loanPrecentageLabel.text = "0.0%"
//        }
        
//        if let salary = Double(salaryTextField.text ?? "0"),
//            let others = Double(othersTextField.text ?? "0") {
////            othersSalaryRatio = others / salary * 100
//            othersPrecentageLabel.text = String(format: "%.1f",
//                                                others / salary * 100) + "%"
//        } else {
//            othersPrecentageLabel.text = "0.0%"
//        }
        
    }
    
    @IBAction func eatEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"),
            let eat = Double(eatTextField.text ?? "0") {
//                eatSalaryRatio = eat / salary * 100
                eatPrecentageLabel.text = String(format: "%.1f",
                                                 eat / salary * 100) + "%"
        }
    }
    
    @IBAction func loanEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"),
            let loan = Double(loanTextField.text ?? "0") {
//                loanSalaryRatio = loan / salary * 100
                loanPrecentageLabel.text = String(format: "%.1f",
                                                  loan / salary * 100) + "%"
        }
    }
    
    @IBAction func othersEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"),
            let others = Double(othersTextField.text ?? "0") {
//            othersSalaryRatio = others / salary * 100
            othersPrecentageLabel.text = String(format: "%.1f",
                                                others / salary * 100) + "%"
        }
    }
    
    //MARK: - Methods
    private func keyboardReturn() {
        salaryTextField.delegate = self
        eatTextField.delegate = self
        loanTextField.delegate = self
        othersTextField.delegate = self
    }
    
    private func salaryRatio(something: Double, salary: Double) -> CGFloat {
        CGFloat(something / salary * 100)
    }
    
    private func drawing() {
        let fullScreenSize = UIScreen.main.bounds.size
        let aDegree = CGFloat.pi / 180
        let radius: CGFloat = 60
        var startDegree: CGFloat = 270
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius))
        
        for percentage in percentages {
            let endDegree = startDegree + 360 * percentage / 100
        
            let percentagePath = UIBezierPath()
            percentagePath.move(to: myView.center)
            percentagePath.addArc(withCenter: myView.center, radius: radius, startAngle: aDegree *  startDegree, endAngle: aDegree * endDegree, clockwise: true)
        
            let percentageLayer = CAShapeLayer()
            percentageLayer.path = percentagePath.cgPath
            
            percentageLayer.fillColor  = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1).cgColor
            
            myView.layer.addSublayer(percentageLayer)
            startDegree = endDegree
        }
        
        myView.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/1.45)
        self.view.addSubview(myView)
    }
    
    // 按下其他非輸入框的位置，鍵盤收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    // 按下 Return 鍵盤收回
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


// 使用 SwiftUI 的預覽功能
struct ViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "\(ViewController.self)") as! ViewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) { }
    
//    typealias UIViewControllerType = ViewController
}

struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewControllerView()
                .previewDevice("iPhone 12 mini")
        }
    }
}
