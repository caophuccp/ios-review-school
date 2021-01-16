//
//  UserProfileViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class UserProfileViewController:UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var chatModeSwitch: UISwitch!
    @IBOutlet weak var universityButton: UIButton!
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordFormView: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var pfvHeightConstraint: NSLayoutConstraint!
    var pfvShown = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.hideKeyboardWhenTappedAround()
    }
    
    func setupViews() {
        passwordFormView.layer.masksToBounds = true
        pfvShown = false
        pfvHeightConstraint.constant = 0
        avatarView.rounded(borderWidth: 0, color: .clear, cornerRadius: 60)
        universityButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        changePasswordButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
    }
    
    @IBAction func changePasswordButtonClick(_ sender: Any) {
        pfvShown.toggle()
        let newHeight:CGFloat = pfvShown ? 160 : 0
        pfvHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    @IBAction func universityButtonClick(_ sender: Any) {
    }
}
