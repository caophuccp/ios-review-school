//
//  ReviewTableCell.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class ReviewTableCell:UITableViewCell {
    @IBOutlet weak var shadowImageView: UIView!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var starStackView: RatingView!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var contentReviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setupViews(review:Review){
        reviewImageView.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        shadowImageView.layer.masksToBounds = false
        shadowImageView.layer.shadowColor = UIColor.black.cgColor
        shadowImageView.layer.shadowOffset = .zero
        shadowImageView.layer.shadowOpacity = 0.7
        shadowImageView.layer.shadowRadius = 4
        shadowImageView.layer.cornerRadius = 10
        
        usernameLabel.adjustsFontSize(minScale: 0.5)
        schoolNameLabel.adjustsFontSize(minScale: 0.5)
        
        usernameLabel.text = review.userID
        contentReviewLabel.text = review.content
        dateLabel.text = review.dateCreatedString
        userAvatarView.rounded(borderWidth: 0, color: .clear, cornerRadius: 15)
        userAvatarView.contentMode = .scaleAspectFill
        
        starStackView.star = review.star
        
        if let url = URL(string: review.image) {
            NetworkImage.shared.download(url: url) { [weak self ](image) in
                DispatchQueue.main.async {
                    self?.reviewImageView.image = image
                }
            }
        }
        
        SchoolModel.shared.get(documentID: review.schoolID) { [weak self](school, error) in
            if let school = school {
                DispatchQueue.main.async {
                    self?.schoolNameLabel.text = school.name
                }
            }
        }
        
        UserModel.shared.get(documentID: review.userID) { [weak self](user, error) in
            if let user = user {
                DispatchQueue.main.async {
                    self?.usernameLabel.text = user.username
                }
                NetworkImage.shared.download(urlString: user.avatar) {(image) in
                    DispatchQueue.main.async {
                        self?.userAvatarView.image = image
                    }
                }
            }
        }
    }
    
}
