//
//  AddEditReviewViewController.swift
//  ReviewSchool
//
//  Created by Pham Van Minh Nhut on 1/21/21.
//

import UIKit

class AddEditReviewViewController: BaseViewController{
    var qrCode: String = ""
    
    @IBOutlet weak var schoolNameLabel: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        settupView()
        view.hideKeyboardWhenTappedAround()
        
//        SchoolModel.shared.get(documentID: user?.chatSchool ?? "") { [weak self] (school, error) in
//            self?.schoolButton.setTitle(school?.name ?? "Tất cả", for: .normal)
//        }
    }
    func settupView(){
        contentTextView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        schoolNameLabel.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        ratingView.isUserInteractionEnabled = true
        doneButton.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
    }
    
    @IBAction func backButtonOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButtonOnClick(_ sender: Any) {
    }
    
}
