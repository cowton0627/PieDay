//
//  ViewController.swift
//  Demo_018
//
//  Created by 鄭淳澧 on 2021/7/30.
//

import UIKit
import SwiftUI

//protocol SendData: class {
//    func receiveData(data: String)
//}
var result: Double = 0

class ViewController: UIViewController {

//    weak var delegate: SendData?
    
    // MARK: - IBOutlet
    // 輸入欄位
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var eatTextField: UITextField!
    @IBOutlet weak var loanTextField: UITextField!
    @IBOutlet weak var othersTextField: UITextField!
    // 百分比呈現
    @IBOutlet weak var eatPrecentageLabel: UILabel!
    @IBOutlet weak var loanPrecentageLabel: UILabel!
    @IBOutlet weak var othersPrecentageLabel: UILabel!
    // MARK: - Properties
    private let screenSize = UIScreen.main.bounds.size
    private let radian = CGFloat.pi / 180
    // 百分比預算
//    private var eatSalaryRatio: Double = 0
//    private var loanSalaryRatio: Double = 0
//    private var othersSalaryRatio: Double = 0
//    private var lastRatio: Double = 0
    
    private var percentDict: [String:CGFloat] = [:]
    private var percentages: [CGFloat] = []
    
    private var drawingCount = 0
    private var pieCount = 0
    private var donutCount = 0
    private let radius: CGFloat = 110
    
    var sharedData: Double?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let sharedData = sharedData {
            othersTextField.text = "\(sharedData)"
        }
    }
    
    // MARK: - Private Functions
    private func drawPie() {
        let radius = self.radius
        var startDegree: CGFloat = 270
        let myView = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 2 * radius,
                                          height: 2 * radius))
        
        for (key,value) in percentDict {
            let endDegree = startDegree + 360 * (value / 100)

            let percentagePath = UIBezierPath()
            percentagePath.move(to: myView.center)
            percentagePath.addArc(withCenter: myView.center,
                                  radius: radius,
                                  startAngle: startDegree * radian,
                                  endAngle: endDegree * radian,
                                  clockwise: true)

            let percentageLayer = CAShapeLayer()
            percentageLayer.path = percentagePath.cgPath
            
            if key == "eat" { percentageLayer.fillColor = UIColor.systemBlue.cgColor }
            else if key == "loan" { percentageLayer.fillColor = UIColor.systemYellow.cgColor }
            else if key == "others" { percentageLayer.fillColor = UIColor.systemGreen.cgColor }
            else if key == "last" { percentageLayer.fillColor = UIColor.systemOrange.cgColor }

            myView.layer.addSublayer(percentageLayer)
            startDegree = endDegree
        }
//        for percentage in percentages {
//            let endDegree = startDegree + 360 * percentage / 100
//
//            let percentagePath = UIBezierPath()
//            percentagePath.move(to: myView.center)
//            percentagePath.addArc(withCenter: myView.center,
//                                  radius: radius,
//                                  startAngle: aDegree *  startDegree,
//                                  endAngle: aDegree * endDegree,
//                                  clockwise: true)
//            let percentageLayer = CAShapeLayer()
//            percentageLayer.path = percentagePath.cgPath
//
//            percentageLayer.fillColor  = UIColor(red: CGFloat.random(in: 0...1),
//                                                 green: CGFloat.random(in: 0...1),
//                                                 blue: CGFloat.random(in: 0...1),
//                                                 alpha: 1).cgColor
//
//            myView.layer.addSublayer(percentageLayer)
//            startDegree = endDegree
//        }
        myView.center = CGPoint(x: screenSize.width / 2,
                                y: screenSize.height / 1.45)
        self.view.addSubview(myView)
    }
    
    private func drawDonut() {
        let radius = self.radius
        let lineWidth: CGFloat = 40.0
        let center = CGPoint(x: screenSize.width / 2,
                             y: screenSize.height / 1.45)
        let ringPath = UIBezierPath(arcCenter: center,
                                    radius: radius - lineWidth / 2,
                                    startAngle: 270 * radian,
                                    endAngle: -90 * radian,
                                    clockwise: false)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = ringPath.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        view.layer.addSublayer(backgroundLayer)

        var startDegree: CGFloat = 270
//        for (key, value) in percentDict {
//            let endDegree = startDegree - 360 * value / 100
//            let percentagePath = UIBezierPath(arcCenter: center,
//                                              radius: radius - lineWidth / 2,
//                                              startAngle: startDegree * radian,
//                                              endAngle: endDegree * radian,
//                                              clockwise: false)
//            let percentageLayer = CAShapeLayer()
//            percentageLayer.path = percentagePath.cgPath
//
//            if key == "eat" { percentageLayer.fillColor = UIColor.systemYellow.cgColor }
//            else if key == "loan" { percentageLayer.fillColor = UIColor.systemBrown.cgColor }
//            else if key == "others" { percentageLayer.fillColor = UIColor.systemOrange.cgColor }
//            else if key == "last" { percentageLayer.fillColor = UIColor.purple.cgColor }
//
//            percentageLayer.fillColor = UIColor.clear.cgColor
//            percentageLayer.lineWidth = lineWidth
//            view.layer.addSublayer(percentageLayer)
//            startDegree = endDegree
//        }
        
        for percentage in percentages {
            let endDegree = startDegree - 360 * percentage / 100
            let percentagePath = UIBezierPath(arcCenter: center,
                                              radius: radius - lineWidth / 2,
                                              startAngle: startDegree * radian,
                                              endAngle: endDegree * radian,
                                              clockwise: false)
            let percentageLayer = CAShapeLayer()
            percentageLayer.path = percentagePath.cgPath

            percentageLayer.strokeColor = UIColor(red: CGFloat.random(in: 0...1),
                                                  green: CGFloat.random(in: 0...1),
                                                  blue: CGFloat.random(in: 0...1),
                                                  alpha: 1).cgColor
            percentageLayer.fillColor = UIColor.clear.cgColor
            percentageLayer.lineWidth = lineWidth
            view.layer.addSublayer(percentageLayer)
            startDegree = endDegree
        }
    }
    
    private func configureUI() {
        salaryTextField.delegate = self
        eatTextField.delegate = self
        loanTextField.delegate = self
        othersTextField.delegate = self
//        othersTextField.text = "\(firstPageBalance)"
    }
    
    private func showBlankAlert() {
        let alertController = UIAlertController(title: "Caution",
                                                message: "Do not leave any fields blank",
                                                preferredStyle: .alert)
        let notOkAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        alertController.addAction(notOkAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    @IBAction func pieChartBtnPressed(_ sender: UIButton) {
        if let salary = Double(salaryTextField.text ?? "0"),
            let eat =  Double(eatTextField.text ?? "0"),
            let loan = Double(loanTextField.text ?? "0"),
            let others = Double(othersTextField.text ?? "0") {
            result = salary - eat - loan - others
            let eatRatio = eat / salary * 100
            let loanRatio = loan / salary * 100
            let othersRatio = others / salary * 100
            let lastRatio = result / salary * 100
            
            percentDict["eat"] = CGFloat(eatRatio)
            percentDict["loan"] = CGFloat(loanRatio)
            percentDict["others"] = CGFloat(othersRatio)
            percentDict["last"] = CGFloat(lastRatio)
            drawPie()
    
        } else {
            showBlankAlert()
        }
        
//        UserDefaults.setValue(result, forKey: "monthDeposit")
        print(result)
//        delegate?.receiveData(data: String(result))
        pieCount += 1
    }
    
    @IBAction func donutChartBtnPressed(_ sender: UIButton) {
        // Pie Chart 畫完後要移除
        if pieCount > 0 {
            for _ in 0...(pieCount-1) {
                view.subviews.last?.removeFromSuperview()
                pieCount = 0
            }
        }

        if let salary = Double(salaryTextField.text ?? "0"),
            let eat =  Double(eatTextField.text ?? "0"),
            let loan = Double(loanTextField.text ?? "0"),
            let others = Double(othersTextField.text ?? "0") {
            result = salary - eat - loan - others
            let eatRatio = eat / salary * 100
            let loanRatio = loan / salary * 100
            let othersRatio = others / salary * 100
            let lastRatio = result / salary * 100
    
            percentages.append(CGFloat(eatRatio))
            percentages.append(CGFloat(loanRatio))
            percentages.append(CGFloat(othersRatio))
            percentages.append(CGFloat(lastRatio))
            drawDonut()
            
        } else {
            showBlankAlert()
        }
        
        print(result)
        // 但 Donut Chart 無論怎麼畫, view.subviews.last 都沒有增加, 所以不做移除
        donutCount += 1
        
    }
    
    @IBAction func salaryEntered(_ sender: UITextField) {
        guard let salary = Double(salaryTextField.text ?? "0") else { return }
        
        if let eat = Double(eatTextField.text ?? "") {
            eatPrecentageLabel.text = String(format: "%.1f", eat / salary * 100) + "%"
        } else {
            eatPrecentageLabel.text = "0.0" + "%"
        }
        
        if let loan = Double(loanTextField.text ?? "0") {
            loanPrecentageLabel.text = String(format: "%.1f", loan / salary * 100) + "%"
        } else {
            loanPrecentageLabel.text = "0.0" + "%"
        }
        
        if let others = Double(othersTextField.text ?? "0") {
            othersPrecentageLabel.text = String(format: "%.1f", others / salary * 100) + "%"
        } else {
            othersPrecentageLabel.text = "0.0%"
        }
        
    }
    
    @IBAction func eatEntered(_ sender: UITextField) {
        guard let salary = Double(salaryTextField.text ?? "0") else { return }
        if let eat = Double(eatTextField.text ?? "0") {
            eatPrecentageLabel.text = String(format: "%.1f", eat / salary * 100) + "%"
        }

    }
    @IBAction func loanEntered(_ sender: UITextField) {
        guard let salary = Double(salaryTextField.text ?? "0") else { return }
        if let loan = Double(loanTextField.text ?? "0") {
            loanPrecentageLabel.text = String(format: "%.1f", loan / salary * 100) + "%"
        }
    }
    @IBAction func othersEntered(_ sender: UITextField) {
        guard let salary = Double(salaryTextField.text ?? "0") else { return }
        if let others = Double(othersTextField.text ?? "0") {
            othersPrecentageLabel.text = String(format: "%.1f", others / salary * 100) + "%"
        }
    }
    
    // 點旁邊鍵盤收回
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension ViewController: UITextFieldDelegate {
    // 點 return 鍵盤收回
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    // 保證使用者輸入數字或小數點
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}

// 嫁接 SwiftUI 預覽功能
//struct ViewControllerView: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> ViewController {
//         let sb = UIStoryboard(name: "Main", bundle: nil)
//         let vc = sb.instantiateViewController(identifier: "ViewController") as! ViewController
//         return vc
//    }
//
//    func updateUIViewController(_ uiViewController: ViewController,
//                                context: Context) {
//    }
//
//    typealias UIViewControllerType = ViewController
//}

// 設定 SwiftUI 預覽
//struct ViewControllerView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ViewControllerView()
//                .previewDevice("iPhone 14 Pro")
//        }
//    }
//}
