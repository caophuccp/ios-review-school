//
//  ViewController.swift
//  ReviewSchool
//
//
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var signInSwitchButton: UIButton!
    @IBOutlet weak var signUpSwitchButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usernameTextField: RoundTextField!
    @IBOutlet weak var passwordTextField: RoundTextField!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    let auth = Auth.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        self.view.hideKeyboardWhenTappedAround()
    }
    
    func setupViews(){
        headerView.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMaxYCorner]
        signInButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        signInSwitchButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        signUpSwitchButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auth.checkAuthState {[weak self] user in
            if user != nil {
                DispatchQueue.main.async {
                    self?.goChat()
                }
            }
        }
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        auth.signIn(email: usernameTextField.text!, password: passwordTextField.text!) { [weak self] (user, err) in
            if let _ = user {
                DispatchQueue.main.async {
                    self?.goChat()
                }
            }
        }
    }
    
    func goChat(){
        usernameTextField.text = ""
        passwordTextField.text = ""
        let tab = TabBarViewController()
        tab.modalPresentationStyle = .fullScreen
        self.present(tab, animated: true, completion: nil)
    }
}
