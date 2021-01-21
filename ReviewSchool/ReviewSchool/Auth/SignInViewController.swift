//
//  ViewController.swift
//  ReviewSchool
//
//
//

import UIKit
import Firebase

class SignInViewController: BaseViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var signInSwitchButton: UIButton!
    @IBOutlet weak var signUpSwitchButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: RoundTextField!
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
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        signInButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        signInSwitchButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        signUpSwitchButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordOnClick(_:)))
        forgotPasswordLabel.isUserInteractionEnabled = true
        forgotPasswordLabel.addGestureRecognizer(recognizer)
    }
    
    @objc func forgotPasswordOnClick(_ sender:UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Forgot Password", message: "Type your email", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: {(action) in
            if let email = alert.textFields?.first?.text {
                DispatchQueue.main.async {
                    self.resetPassword(email: email)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(email:String){
        if !Validator.isValid(email: email) {
            alertError(title: "Forgot Password", message: "Invalid Email")
            return
        }
        auth.sendPasswordReset(email: email) { [weak self] (error) in
            if let error = error {
                self?.alertError(title: "Forgot Password", message: error.localizedDescription)
                return
            }
            self?.alertError(title: "Forgot Password", message: "Please check your email for reset password")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disableUserInteraction()
        auth.checkAuthState {[weak self] user in
            if user != nil {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.goMain()
                }
            } else {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                }
            }
        }
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        let validateResult = validate()
        if (validateResult.error) {
            alertError(title: "Review App", message: validateResult.message)
            return
        }
        disableUserInteraction()
        auth.signIn(email: emailTextField.text!, password: passwordTextField.text!) { [weak self] (user, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.alertError(title: "Sign In", message: error.localizedDescription)
                }
                return
            }
            if user != nil {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.goMain()
                }
            } else {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.alertError(title: "Sign In", message: "An Unknown Error")
                }
            }
        }
    }
    
    func validate() -> Validator.ValidationError {
        if !Validator.isValid(email: emailTextField.text ?? "") {
            return Validator.ValidationError(error: true, message: "Invalid Email")
        }
        return Validator.ValidationError(error: false, message: nil)
    }
    
    func goMain(){
        emailTextField.text = ""
        passwordTextField.text = ""
        if User.Role.Admin == auth.currentUser?.role{
            let tab = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "AdminTabController")
            tab.modalPresentationStyle = .fullScreen
            self.present(tab, animated: true, completion: nil)
        }
        else {
            let tab = TabBarViewController()
            tab.modalPresentationStyle = .fullScreen
            self.present(tab, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInSwitchOnClick(_ sender: Any) {
        //        let vc = storyboard!.instantiateViewController(withIdentifier: "SignInViewController")
        //        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true, completion: nil)
        //        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpSwitchOnClick(_ sender: Any) {
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "SignUpViewController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
