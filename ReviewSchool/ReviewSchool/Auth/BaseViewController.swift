//
//  BaseViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit

class BaseViewController:UIViewController {
    
    let indicatorView = UIActivityIndicatorView.large()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addIndicatorView()
    }
    
    func addIndicatorView(){
        self.view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func enableUserInteraction(){
        indicatorView.stopAnimating()
        view.isUserInteractionEnabled = true
        view.alpha = 1
    }
    
    func disableUserInteraction(){
        view.isUserInteractionEnabled = false
        view.alpha = 0.8
        view.bringSubviewToFront(indicatorView)
        indicatorView.startAnimating()
    }
    
}
