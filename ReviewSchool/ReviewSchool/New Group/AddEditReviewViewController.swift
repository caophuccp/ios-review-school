//
//  AddEditReviewViewController.swift
//  ReviewSchool
//
//  Created by Pham Van Minh Nhut on 1/21/21.
//

import UIKit

class AddEditReviewViewController: BaseViewController{
    @IBOutlet weak var schoolNameLabel: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var doneButton: UIButton!
    
    var selectedImageURL:URL?
    var school:School!
    
    var isTextViewEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settupView()
        view.hideKeyboardWhenTappedAround()
    }
    func settupView(){
        contentTextView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        schoolNameLabel.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        ratingView.isUserInteractionEnabled = true
        doneButton.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editImage))
        imageImageView.isUserInteractionEnabled = true
        imageImageView.addGestureRecognizer(tapGestureRecognizer)
        
        schoolNameLabel.setTitle(school.name, for: .normal)
        schoolNameLabel.titleLabel?.adjustsFontSize(minScale: 0.8)
        
        contentTextView.delegate = self
        contentTextView.text = "Write any thing"
        contentTextView.textColor = .darkGray
    }
    
    @IBAction func backButtonOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonOnClick(_ sender: Any) {
        let review = Review(userID: Auth.shared.currentUser!.uid, schoolID: school.id, star: ratingView.star)
        review.content = isTextViewEmpty ? "" : contentTextView.text
        disableUserInteraction()
        if let url = selectedImageURL {
            FirebaseStorage.shared.putFile(imageURL: url) { [weak self] (downloadURl, error) in
                if let downloadURl = downloadURl {
                    review.image = downloadURl.absoluteString
                    self?.addNewReview(review)
                } else {
                    self?.enableUserInteraction()
                    self?.alertError(title: "Erorr", message: error?.localizedDescription ?? "An Unknown Error")
                }
            }
        } else {
            addNewReview(review)
        }
    }
    
    func addNewReview(_ review: Review){
        ReviewModel.shared.save(review: review) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.enableUserInteraction()
                    self?.alertError(title: "Erorr", message: error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func editImage(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
}

extension AddEditReviewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL, let image = info[.originalImage] as? UIImage{
            imageImageView.image = image
            selectedImageURL = url
        }
    }
}

extension AddEditReviewViewController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if isTextViewEmpty {
            contentTextView.text = ""
            isTextViewEmpty = false
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isTextViewEmpty {
            contentTextView.textColor = .darkText
            contentTextView.text = ""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if contentTextView.text == "" {
            contentTextView.text = "Write any thing"
            contentTextView.textColor = .darkGray
        } else {
            isTextViewEmpty = false
        }
        return true
    }
}
