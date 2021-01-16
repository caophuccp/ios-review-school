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
    
    let auth = Firebase.Auth.auth()
    
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
        if auth.currentUser != nil {
            goChat()
        }
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        auth.signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { [weak self] (auth, err) in
            if let _ = auth {
                DispatchQueue.main.async {
                    self?.goChat()
                }
            }
        }
    }
    
    func goChat(){
        let tab = TabBarViewController()
        tab.modalPresentationStyle = .fullScreen
        self.present(tab, animated: true, completion: nil)
    }
}
