//
//  SignUpController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit

class SignUpViewController: BaseViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var signInSwitchButton: UIButton!
    @IBOutlet weak var signUpSwitchButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: RoundTextField!
    @IBOutlet weak var usernameTextField: RoundTextField!
    @IBOutlet weak var passwordTextField: RoundTextField!
    
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
    }
    
    @IBAction func signInButtonOnClick(_ sender: Any) {
        let validateResult = validate()
        if !validateResult.error {
            let password = passwordTextField.text ?? ""
            let user = getUserFromForm()
            disableUserInteraction()
            Auth.shared.createUser(user: user, password: password) { [weak self](user, error) in
                if error == nil && user != nil {
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
        } else {
            alertError(title: "Review App", message: validateResult.message)
        }
    }
    
    func alertError(title:String?, message: String?){
        if presentedViewController == nil {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getUserFromForm() -> User{
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let user = User()
        user.username = username
        user.email = email
        return user
    }
    
    func validate() -> Validator.ValidationError {
        if !Validator.isValid(email: emailTextField.text ?? "") {
            return Validator.ValidationError(error: true, message: "Invalid Email")
        }
        if !Validator.isValid(username: usernameTextField.text ?? "") {
            return Validator.ValidationError(error: true, message: "Invalid Username")
        }
        if !Validator.isValid(password: passwordTextField.text ?? "") {
            return Validator.ValidationError(error: true, message: "Invalid Passwors")
        }
        return Validator.ValidationError(error: false, message: nil)
    }
    
    func goMain(){
        emailTextField.text = ""
        passwordTextField.text = ""
        usernameTextField.text = ""
        let tab = TabBarViewController()
        tab.modalPresentationStyle = .fullScreen
        self.present(tab, animated: true, completion: nil)
    }
    
    @IBAction func signInSwitchOnClick(_ sender: Any) {
        //do nothing
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpSwitchOnClick(_ sender: Any) {
//        let vc = storyboard!.instantiateViewController(withIdentifier: "SignUpViewController")
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
    }
    
}
