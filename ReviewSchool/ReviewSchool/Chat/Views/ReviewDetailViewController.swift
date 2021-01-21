//
//  ReviewDetailViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class ReviewDetailViewController:BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var reviewContentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var review:Review!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setData()
    }
    
    func setupViews(){
        headerView.rounded(borderWidth: 0, color: .clear, cornerRadius: 15)
        headerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        schoolNameLabel.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        schoolNameLabel.adjustsFontSize(minScale: 0.5)
//
        imageShadowView.layer.masksToBounds = false
        imageShadowView.layer.shadowColor = UIColor.black.cgColor
        imageShadowView.layer.shadowOffset = .zero
        imageShadowView.layer.shadowOpacity = 0.7
        imageShadowView.layer.shadowRadius = 4
        imageShadowView.layer.cornerRadius = 10
        imageShadowView.backgroundColor = .white
        reviewImageView.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)

        addressLabel.adjustsFontSize(minScale: 0.5)
        addressLabel.numberOfLines = 2
        addressLabel.lineBreakMode = .byWordWrapping
        
        reviewContentLabel.numberOfLines = 0
        reviewContentLabel.lineBreakMode = .byWordWrapping
    }
    
    func setData(){
        reviewContentLabel.text = review.content
        dateLabel.text = review.dateCreatedString
        NetworkImage.shared.download(urlString: review.image) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.reviewImageView.image = image
                self?.updateImageConstraint()
            }
        }
        SchoolModel.shared.get(documentID: review.schoolID) { [weak self] (school, error) in
            if let school = school {
                DispatchQueue.main.async {
                    self?.schoolNameLabel.text = school.name
                    self?.addressLabel.text = school.address
                }
            }
        }
    }
    
    func updateImageConstraint(){
        if let image = reviewImageView.image {
            let aspect = image.size.width/image.size.height
            imageShadowView.constraints.first(where: {$0.firstAttribute == .width})?.isActive = false
            imageShadowView.widthAnchor.constraint(equalTo: imageShadowView.heightAnchor, multiplier: aspect).isActive = true
        }
    }
    
    @IBAction func backButtonOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
