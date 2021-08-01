//
//  DepositViewController.swift
//  Demo_018
//
//  Created by 鄭淳澧 on 2021/7/31.
//

import UIKit



class DepositViewController: UIViewController, UITextFieldDelegate {
//    func receiveData(data: String) {
//        depositTextField.text = data
//    }
    
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var depositTextField: UILabel!
    
    var percent: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetTextField.delegate = self
        depositTextField.text = String(format: "%.0f", result)
        
        
    }
    
    func drawing(percentage: CGFloat) -> UIView {
        let fullScreenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        myView.backgroundColor = .blue
        
        let lineWidth: CGFloat = 20
        let radius: CGFloat = 60
        let aDegree = CGFloat.pi / 180
        let startDegree: CGFloat = 270
        
        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth, y: lineWidth, width: radius*2, height: radius*2))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.gray.cgColor
        
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        
        let percentagePath = UIBezierPath(arcCenter: CGPoint(x: (lineWidth + radius), y: lineWidth + radius), radius: radius, startAngle: aDegree * startDegree, endAngle: aDegree * (startDegree + 360 * percentage), clockwise: true)
        
        let percentageLayer = CAShapeLayer()
        percentageLayer.path = percentagePath.cgPath
        percentageLayer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor
        
        percentageLayer.lineWidth = lineWidth
        percentageLayer.fillColor = UIColor.clear.cgColor
        
        
        let labell = UILabel(frame: CGRect(x: 0, y: 0, width: 2*(lineWidth + radius), height: 2*(lineWidth + radius)))
        labell.textAlignment = .center
        labell.text = String(format: "%.2f", percent * 100) + "%"
        
        let vieww = UIView(frame: labell.frame)
        vieww.addSubview(labell)
        vieww.layer.addSublayer(circleLayer)
        vieww.layer.addSublayer(percentageLayer)
        
        vieww.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/1.45)

        self.view.addSubview(vieww)
        return vieww
    }
    
    
    @IBAction func targetEntered(_ sender: UITextField) {
        if let deposit = Double(depositTextField.text ?? "0"), let target =  Double(targetTextField.text ?? "0") {
            percent = deposit / target
        } else {
            let alertController = UIAlertController(title: "Caution", message: "Do not leave target field blank", preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }
        print("\(percent)")

    }
    
    @IBAction func drawBtnPressed(_ sender: UIButton) {
        if targetTextField.text?.isEmpty == false {
            drawing(percentage: CGFloat(percent))
        } else {
            let alertController = UIAlertController(title: "Caution", message: "Do not leave target field blank", preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
