//
//  SchoolViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit

class SchoolViewController:BaseViewController {
    enum ViewStyle {
        case none
        case update
        case add
    }
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameTextField: RoundTextField!
    @IBOutlet weak var addressTextField: RoundTextField!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var leftButton: UIButton?
    @IBOutlet weak var rightButton: UIButton?
    
    var avatarURL:URL?
    var school:School?
    var schoolID = UUID().uuidString
    var editingStyle = ViewStyle.none {
        didSet {
            reloadButtonTitle()
        }
    }
    
    
    func reloadButtonTitle(){
        let rightButtonTitle:String
        let leftButtonTitle:String
        if (editingStyle == .add) {
            leftButtonTitle = "Cancel"
            rightButtonTitle = "Add"
        } else {
            leftButtonTitle = "Delete"
            rightButtonTitle = "Update"
            
        }
        rightButton?.setTitle(rightButtonTitle, for: .normal)
        leftButton?.setTitle(leftButtonTitle, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let s = school {
            setData(school: s)
        } else {
            newForm()
        }
    }
    
    func setupViews(){
        leftButton?.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        rightButton?.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        reloadButtonTitle()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(qrImageLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        qrImageView.isUserInteractionEnabled = true
        qrImageView.addGestureRecognizer(longPressRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editAvatar))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func editAvatar(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }

    private func newForm(){
        qrImageView.image = QRCodeHelper.generateQRCode(from: "reviewapp-schoolid: \(schoolID)")
    }
    
    private func setData(school:School){
        schoolID = school.id
        nameTextField.text = school.name
        addressTextField.text = school.address
        qrImageView.image = QRCodeHelper.generateQRCode(from: "reviewapp-schoolid: \(schoolID)")
        qrImageView.backgroundColor = .clear
        if let url = URL(string: school.avatar) {
            NetworkImage.shared.download(url: url){ [weak self] (image) in
                self?.avatarView.image = image
            }
        }
    }
    
    @objc func qrImageLongPress(_ sender:UILongPressGestureRecognizer){
        if (sender.state == .began) {
            let alert = UIAlertController(title: nil, message: "Save to photos album", preferredStyle: .actionSheet)
            let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
                self.saveQRCodeToAlbum()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    func saveQRCodeToAlbum(){
        if let qrImage = qrImageView.image {
            UIImageWriteToSavedPhotosAlbum(qrImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
         if let error = error {
             // we got back an error!
             let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "OK", style: .default))
             present(ac, animated: true)
         } else {
                avatarView.image = image
             let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "OK", style: .default))
             present(ac, animated: true)
         }
     }
    
    @IBAction func leftButtonOnClick(_ sender: Any) {
        if editingStyle == .add {
            dismiss()
        } else {
            confirmDeleteCurrentSchool()
        }
    }
    
    @IBAction func rightButtonOnClick(_ sender: Any) {
        saveSchool()
    }

    func saveSchool(){
        let name = nameTextField.text ?? ""
        let address = addressTextField.text ?? ""
        if (name.isEmpty) {
            nameTextField.hasError = true
            alertError(title: nil, message: "Name can not be empty\nPlease enter a valid name.")
            return
        }
        if (address.isEmpty) {
            addressTextField.hasError = true
            alertError(title: nil, message: "Address can not be empty\nPlease enter a valid address.")
            return
        }
        
        self.disableUserInteraction()
        let newSchool = School(id: schoolID, name: name, address: address)
        if let avatar = school?.avatar {
            newSchool.avatar = avatar
        }
        if let avatarURL = avatarURL {
            FirebaseStorage.shared.putFile(imageURL: avatarURL) { [weak self] (downloadURL, error) in
                if let url = downloadURL {
                    newSchool.avatar = url.absoluteString
                    self?.saveSchool(newSchool)
                } else {
                    DispatchQueue.main.async {
                        self?.enableUserInteraction()
                        self?.alertError(title: "Error", message: "Cannot upload image to server")
                    }
                }
            }
        } else
        {
            saveSchool(newSchool)
        }
    }
    
    func saveSchool(_ school:School){
        SchoolModel.shared.save(school: school) { [weak self](error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.alertError(title: "Error", message: error.localizedDescription)
                }
            } else {
                self?.dismiss()
            }
        }
    }
    
    func confirmDeleteCurrentSchool(){
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this school", preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.deleteCurrentSchool()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: false, completion: nil)
    }
    
    func deleteCurrentSchool(){
        SchoolModel.shared.delete(documentID: schoolID) { [weak self](error) in
            if let error = error {
                self?.alertError(title: "Error", message: error.localizedDescription)
            } else {
                self?.dismiss()
            }
        }
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension SchoolViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL, let image = info[.originalImage] as? UIImage{
            avatarView.image = image
            avatarURL = url
        }
    }
}
