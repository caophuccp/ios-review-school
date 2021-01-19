//
//  UIViewExtension.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

extension UIView {
    func rounded(borderWidth: CGFloat, color:UIColor, cornerRadius:CGFloat) {
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = cornerRadius
    }
    
    func hideKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard(){
        self.endEditing(true)
    }
}

extension UIActivityIndicatorView {
    static func large() -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            indicatorView.style = .large
        } else {
            indicatorView.style = .gray
        }
        return indicatorView
    }
}
