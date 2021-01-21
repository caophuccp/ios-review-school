//
//  UserProfileViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class UserProfileViewController:BaseViewController, SchoolPickerViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var chatModeSwitch: UISwitch!
    @IBOutlet weak var schoolButton: UIButton!
    
    @IBOutlet weak var oldPasswordTextField: RoundTextField!
    @IBOutlet weak var newPasswordTextField: RoundTextField!
    @IBOutlet weak var confirmPasswordTextField: RoundTextField!
    
    @IBOutlet weak var passwordFormView: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var pfvHeightConstraint: NSLayoutConstraint!
    var pfvShown = true
    
    @IBOutlet weak var usernameTextField: RoundTextField!
    @IBOutlet weak var changeUsernameButton: UIButton!
    @IBOutlet weak var utfHeightConstraint: NSLayoutConstraint!
    var utfShown = true
    
    @IBOutlet weak var logoutButton: UIButton!
    var user = Auth.shared.currentUser {
        didSet{
            DispatchQueue.main.async {
                self.setUserData()
            }
        }
    }
    
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
        schoolButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        schoolButton.titleLabel?.minimumScaleFactor = 0.5
        schoolButton.titleLabel?.numberOfLines = 1
        schoolButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        changePasswordButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        changeUsernameButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        logoutButton.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        
        utfShown = false
        utfHeightConstraint.constant = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editAvatar))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tapGestureRecognizer)
        
        setUserData()
        
        self.view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func setUserData(){
        enableUserInteraction()
        usernameLabel.text = user?.username
        chatModeSwitch.isOn = user?.chatMode ?? false
        SchoolModel.shared.get(documentID: user?.chatSchool ?? "") { [weak self] (school, error) in
            self?.schoolButton.setTitle(school?.name ?? "Tất cả", for: .normal)
        }
        if let avatar = user?.avatar, let url = URL(string: avatar) {
            NetworkImage.shared.download(url: url) {(image) in
                DispatchQueue.main.async {
                    self.avatarView.image = image
                }
            }
        }
    }
    
    @objc func editAvatar(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func changePasswordButtonClick(_ sender: Any) {
        view.endEditing(true)
        let oldPassword = oldPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        if pfvShown && (!oldPassword.isEmpty || !newPassword.isEmpty || !confirmPassword.isEmpty) {
            
            if (newPassword != confirmPassword) {
                newPasswordTextField.hasError = true
                confirmPasswordTextField.hasError = true
                
                alertError(title: "Review App", message: "Mật khẩu mới không khớp")
                return
            }
            changeValidPassword(oldPassword: oldPassword, newPassword: newPassword)
            return
        }
        
        passwordForm(edit: !pfvShown)
    }
    
    @IBAction func universityButtonClick(_ sender: Any) {
        let vc = UIStoryboard(name: "Admin", bundle: nil).instantiateViewController(withIdentifier: "AdminSchoolController") as! AdminSchoolController
        vc.pickerDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func changeUsernameButtonClick(_ sender: Any) {
        view.endEditing(true)
        let username = usernameTextField.text ?? ""
        if utfShown && !username.isEmpty{
            changeUsername(newUsername: username)
            return
        }
        
        usernameTextField(edit: !utfShown)
    }
    
    @IBAction func logoutButtonClick(_ sender: Any) {
        Auth.shared.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func schoolPickerViewDidFinish(school:School){
        if let user = user {
            UserModel.shared.updateData(documentID: user.uid, fields: ["chatSchool": school.id]) { [weak self]_ in
                self?.reloadUser()
            }
        }
    }
    
    @IBAction func chatModeSwitchDidChange(_ sender: Any) {
        if let user = user {
            UserModel.shared.updateData(documentID: user.uid, fields: ["chatMode": chatModeSwitch.isOn]) { [weak self]_ in
                self?.reloadUser()
            }
        }
    }
}

extension UserProfileViewController {
    func passwordForm(edit: Bool){
        pfvShown = edit
        let newHeight:CGFloat = pfvShown ? 160 : 0
        pfvHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    func changeValidPassword(oldPassword:String, newPassword:String){
        disableUserInteraction()
        Auth.shared.changePassword(old: oldPassword, new: newPassword) { [weak self](error) in
            if error != nil{
                DispatchQueue.main.async {
                    self?.changePasswordOnFailure()
                }
            } else {
                DispatchQueue.main.async {
                    self?.changePasswordOnSuccess()
                }
            }
        }
    }
    
    func changePasswordOnFailure(){
        enableUserInteraction()
        self.oldPasswordTextField.hasError = true
        self.newPasswordTextField.hasError = true
        self.confirmPasswordTextField.hasError = true
        
        self.alertError(title: "Review App", message: "Đổi mật khẩu thất bại!\nVui lòng xem lại thông tin đã nhập")
    }
    
    func changePasswordOnSuccess(){
        enableUserInteraction()
        self.alertError(title: "Review App", message: "Đổi mật khẩu thành công")
        self.passwordForm(edit: false)
    }
    
    func changeUsername(newUsername: String){
        if let user = user {
            disableUserInteraction()
            UserModel.shared.updateData(documentID: user.uid, fields: ["username": newUsername]) { [weak self](error) in
                if error != nil{
                    DispatchQueue.main.async {
                        self?.changeUsernameOnFailure()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.changeUsernameOnSuccess()
                    }
                }
            }
        } else {
            self.alertError(title: "Review App", message: "An Unknown Error")
        }
    }
    
    func usernameTextField(edit:Bool) {
        utfShown = edit
        let newHeight:CGFloat = utfShown ? 40 : 0
        utfHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    func changeUsernameOnFailure(){
        enableUserInteraction()
        self.usernameTextField.reset()
        self.alertError(title: "Review App", message: "Đổi tên thất bại!\nVui lòng xem lại thông tin đã nhập")
    }
    
    func changeUsernameOnSuccess(){
        self.usernameLabel.text = usernameTextField.text
        self.alertError(title: "Review App", message: "Đổi tên thành công")
        self.oldPasswordTextField.reset()
        self.newPasswordTextField.reset()
        self.confirmPasswordTextField.reset()
        self.passwordForm(edit: false)
        reloadUser()
    }
    
    func reloadUser() {
        Auth.shared.checkAuthState(){(user)in
            self.user = user
        }
    }
}


extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL{
            putFileAndUpdateAvatar(imageURL: url)
        }
    }
    
    func putFileAndUpdateAvatar(imageURL:URL){
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
        }
        FirebaseStorage.shared.putFile(imageURL: imageURL) {[weak self](url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url = url {
                self?.updateAvatar(url: url)
            }
        }
    }
    
    func updateAvatar(url:URL){
        indicatorView.stopAnimating()
        if let user = user {
            UserModel.shared.updateData(documentID: user.uid, fields: ["avatar": url.absoluteString]) {[weak self]_ in
                self?.reloadUser()
            }
        }
    }
    
}
