//
//  ChatTabViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class ChatTabViewController: UIViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews(){
        headerView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 10)
        messageView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        goButton.rounded(borderWidth: 0, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 5)
        
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.textAlignment = .center
        headerLabel.text = ""
        indicatorView.hidesWhenStopped = true
        indicatorView.stopAnimating()
    }
    
    var stop = true;
    @IBAction func goChat(_ sender: Any) {
        if stop {
            indicatorView.startAnimating()
            headerLabel.text = "Chúng tôi đang tìm kiếm bạn chat cho bạn"
        } else {
            indicatorView.stopAnimating()
            headerLabel.text = ""
        }
        stop.toggle()
    }
}
