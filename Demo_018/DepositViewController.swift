//
//  DepositViewController.swift
//  Demo_018
//
//  Created by 鄭淳澧 on 2021/7/31.
//

import UIKit

//MARK: 月存款表，次頁，在 TabBarController 尚未點到此 tag 時，此頁尚未產生
class DepositViewController: UIViewController {
//    func receiveData(data: String) {
//        depositLabel.text = String(format: "%.0f", data)
//    }
    
    //MARK: - IBOutlet
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var depositLabel: UILabel!
    
    //MARK: - Properties
    var percent: Double = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardReturn()
                
//        if let percent = Double(depositLabel.text ?? "0") {
//            self.percent = percent
//        }
        
        depositLabel.text = String(format: "%.0f", data ?? 0)

    }
    
    //MARK: - IBAction
    @IBAction func targetEntered(_ sender: UITextField) {
        if let deposit = Double(depositLabel.text ?? "0"),
            let target =  Double(targetTextField.text ?? "0") {
            
            percent = deposit / target
            
        } else {
            let alertController = UIAlertController(title: "Caution",
                                                    message: "Don't leave target blank",
                                                    preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back",
                                            style: .cancel,
                                            handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }

    }
    
    @IBAction func drawBtnPressed(_ sender: UIButton) {
        if targetTextField.text?.isEmpty == false {
            
            drawing(percentage: CGFloat(percent))
            
        } else {
            let alertController = UIAlertController(title: "Caution",
                                                    message: "Do not leave target blank",
                                                    preferredStyle: .alert)
            let notOkAction = UIAlertAction(title: "Back",
                                            style: .cancel,
                                            handler: nil)
            alertController.addAction(notOkAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Methods
    private func keyboardReturn() {
        targetTextField.delegate = self
    }
    
    private func drawing(percentage: CGFloat) -> UIView {
        let fullScreenSize = UIScreen.main.bounds.size
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        myView.backgroundColor = .blue
        
        let lineWidth: CGFloat = 20
        let radius: CGFloat = 60
        let aDegree = CGFloat.pi / 180
        let startDegree: CGFloat = 270
        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: lineWidth,
                                                     y: lineWidth,
                                                     width: radius * 2,
                                                     height: radius * 2))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        
        circleLayer.strokeColor = UIColor.gray.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        let percentagePath = UIBezierPath(arcCenter: CGPoint(x: lineWidth + radius,
                                                             y: lineWidth + radius),
                                          radius: radius,
                                          startAngle: aDegree * startDegree,
                                          endAngle: aDegree * (startDegree + 360 * percentage),
                                          clockwise: true)
        
        let percentageLayer = CAShapeLayer()
        percentageLayer.path = percentagePath.cgPath
        
        percentageLayer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor
        percentageLayer.lineWidth = lineWidth
        percentageLayer.fillColor = UIColor.clear.cgColor
        
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 2 * (lineWidth + radius),
                                          height: 2 * (lineWidth + radius)))
        label.textAlignment = .center
        label.text = String(format: "%.2f", percent * 100) + "%"
        
        let view = UIView(frame: label.frame)
        view.addSubview(label)
        view.layer.addSublayer(circleLayer)
        view.layer.addSublayer(percentageLayer)
        
        view.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/1.45)

        self.view.addSubview(view)
        return view
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//MARK: - UITextFieldDelegate
extension DepositViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
