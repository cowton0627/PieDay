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

class ViewController: UIViewController, UITextFieldDelegate {

//    weak var delegate: SendData?
    
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var eatTextField: UITextField!
    @IBOutlet weak var loanTextField: UITextField!
    @IBOutlet weak var othersTextField: UITextField!
    
    @IBOutlet weak var eatPrecentageLabel: UILabel!
    @IBOutlet weak var loanPrecentageLabel: UILabel!
    @IBOutlet weak var othersPrecentageLabel: UILabel!
    
    var eatSalaryRatio: Double = 0
    var loanSalaryRatio: Double = 0
    var othersSalaryRatio: Double = 0
    var lastRatio: Double = 0
    
    var percentages: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        salaryTextField.delegate = self
        eatTextField.delegate = self
        loanTextField.delegate = self
        othersTextField.delegate = self
        
//        let myPathView = UIView(frame: myView.frame)
//        myPathView.backgroundColor = .red
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        label.text = ""
        
        //試畫三角路徑
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: 100, y: 0))
//        path.addLine(to: CGPoint(x: 100, y: 100))
//        path.close()
//
//        let myShapeLayer = CAShapeLayer()
//        myShapeLayer.path = path.cgPath
//        myPathView.layer.mask = myShapeLayer
//
//        myView.addSubview(myPathView)
        
        //試畫圓餅路徑
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 50, y: 50))
//        path.addArc(withCenter: CGPoint(x: 50, y: 50), radius: 40, startAngle: aDegree * 0, endAngle: aDegree * 180, clockwise: true)
        
        //試畫圓餅路徑2
//        let path = UIBezierPath(arcCenter: CGPoint(x: 50, y: 50),radius: 50, startAngle: aDegree * 200,endAngle:aDegree * 0, clockwise: true)
//        path.addLine(to: CGPoint(x: 75, y: 50))
//        path.addArc(withCenter: CGPoint(x: 50, y: 50), radius: 25, startAngle: aDegree * 0, endAngle: aDegree * 200, clockwise: false)
        
      
//        let lineWidth: CGFloat = 10
       
//        myView.backgroundColor = .clear
        

//        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth, y: lineWidth, width: radius*2, height: radius*2))
//
//        let circleLayer = CAShapeLayer()
//        circleLayer.path = circlePath.cgPath
//        circleLayer.strokeColor = UIColor.gray.cgColor
        
//        circleLayer.lineWidth = lineWidth
//        circleLayer.fillColor = UIColor.clear.cgColor
        
        
//        percentageLayer.lineWidth = lineWidth
//        percentageLayer.fillColor = UIColor.clear.cgColor
        
        
//        let labell = UILabel(frame: CGRect(x: 0, y: 0, width: 2*(lineWidth + radius), height: 2*(lineWidth + radius)))
//        labell.textAlignment = .center
//        labell.text = "\(percentage)%"
//
//        let vieww = UIView(frame: labell.frame)
//        vieww.addSubview(labell)
//        vieww.layer.addSublayer(circleLayer)
//        vieww.layer.addSublayer(percentageLayer)
        
        
//        let myShapeLayer = CAShapeLayer()
//        myShapeLayer.path = path.cgPath
//        myShapeLayer.fillColor = UIColor.red.cgColor
//        myView.layer.mask = myShapeLayer
//        myView.layer.addSublayer(myShapeLayer)
        
 
//        self.view.addSubview(label)
//        self.view.addSubview(vieww)
        
    }
    func drawing() {
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
    
    @IBAction func resultBtnPressed(_ sender: UIButton) {
        if let salary = Double(salaryTextField.text ?? "0"), let eat =  Double(eatTextField.text ?? "0"), let loan = Double(loanTextField.text ?? "0"), let others = Double(othersTextField.text ?? "0") {
            result = salary - eat - loan - others
            eatSalaryRatio = eat / salary * 100
            loanSalaryRatio = loan / salary * 100
            othersSalaryRatio = others / salary * 100
            lastRatio = result / salary * 100
            
            percentages.append(CGFloat(eatSalaryRatio))
            percentages.append(CGFloat(loanSalaryRatio))
            percentages.append(CGFloat(othersSalaryRatio))
            percentages.append(CGFloat(lastRatio))
            drawing()
            
            
        } else {
            let alertController = UIAlertController(title: "Caution", message: "Do not leave any fields blank", preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }
        
//        UserDefaults.setValue(result, forKey: "monthDeposit")
        print(result)
//        delegate?.receiveData(data: String(result))
        
    }
    
    
    //在第一頁不顯示navigation bar, 但螢幕反應時間會看到上方閃過黑條
//    override func viewWillAppear(_ animated: Bool) {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//            super.viewWillAppear(animated)
//        }
//        override func viewWillDisappear(_ animated: Bool) {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//            super.viewWillDisappear(animated)
//        }

    
    @IBAction func salaryEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"), let eat = Double(eatTextField.text ?? "0") {
            eatSalaryRatio = eat / salary * 100
            print("\(salary)")
            eatPrecentageLabel.text = String(format: "%.1f", eatSalaryRatio) + "%"

        } else {
            eatPrecentageLabel.text = "0.0%"
        }
        if let salary = Double(salaryTextField.text ?? "0"), let loan = Double(loanTextField.text ?? "0") {
            loanSalaryRatio = loan / salary * 100
            loanPrecentageLabel.text = String(format: "%.1f", loanSalaryRatio) + "%"

        } else {
            loanPrecentageLabel.text = "0.0%"
        }
        if let salary = Double(salaryTextField.text ?? "0"), let others = Double(othersTextField.text ?? "0") {
            othersSalaryRatio = others / salary * 100
            othersPrecentageLabel.text = String(format: "%.1f", othersSalaryRatio) + "%"
        } else {
            othersPrecentageLabel.text = "0.0%"
        }
        
    }
    @IBAction func eatEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"), let eat = Double(eatTextField.text ?? "0") {
           
                eatSalaryRatio = eat / salary * 100
                eatPrecentageLabel.text = String(format: "%.1f", eatSalaryRatio) + "%"
        }
    }
    @IBAction func loanEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"), let loan = Double(loanTextField.text ?? "0") {
                
                loanSalaryRatio = loan / salary * 100
                loanPrecentageLabel.text = String(format: "%.1f", loanSalaryRatio) + "%"
        }
    }
    @IBAction func othersEntered(_ sender: UITextField) {
        if let salary = Double(salaryTextField.text ?? "0"), let others = Double(othersTextField.text ?? "0") {
            
            othersSalaryRatio = others / salary * 100
            othersPrecentageLabel.text = String(format: "%.1f", othersSalaryRatio) + "%"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}


//使用SwiftUI的預覽功能
struct ViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
         UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as! ViewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
    
    typealias UIViewControllerType = ViewController
}


struct ViewControllerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewControllerView()
                .previewDevice("iPhone 12 mini")
        }
    }
}
