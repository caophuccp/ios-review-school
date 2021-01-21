//
//  RoundTextField.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class RoundTextField:UITextField {
    var borderColor:CGColor = #colorLiteral(red: 0.7822627425, green: 0.7823951244, blue: 0.7822452188, alpha: 1)
    var focusBorderColor:CGColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    var errorBorderColor:CGColor = #colorLiteral(red: 0.8405033946, green: 0.363564074, blue: 0.4072247744, alpha: 1)
    
    var contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    var hasError = false {
        didSet{
            self.layer.borderColor = errorBorderColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func setup(){
//        self.translatesAutoresizingMaskIntoConstraints = false
        self.autocorrectionType = .no
        self.borderStyle = .none
        
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.7822627425, green: 0.7823951244, blue: 0.7822452188, alpha: 1)
        self.layer.cornerRadius = 5
        
        self.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        self.layer.borderColor = focusBorderColor
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderColor = borderColor
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    func reset(){
        hasError = false
        text = ""
    }
}
