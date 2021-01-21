//
//  UserReviewCell.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class UserReviewTableCell:UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setupViews(delegate: UICollectionViewDelegate, dataSource:UICollectionViewDataSource){
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

class ReviewCollectionCell:UICollectionViewCell {
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    
    func setupViews(review:Review){
        self.imageView.rounded(borderWidth: 0, color: .clear, cornerRadius: 10)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 4
        shadowView.layer.cornerRadius = 10
        
        self.contentLabel.numberOfLines = 0
        self.contentLabel.lineBreakMode = .byWordWrapping
        self.contentLabel.text = review.content
        
        self.dateLabel.text = review.dateCreatedString
//        self.schoolNameLabel.text = review.schoolID
        if let url = URL(string: review.image) {
            NetworkImage.shared.download(url: url) { [weak self](image) in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
        self.contentView.rounded(borderWidth: 2, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 10)
        
        SchoolModel.shared.get(documentID: review.schoolID) { [weak self](school, error) in
            if let school = school {
                DispatchQueue.main.async {
                    self?.schoolNameLabel.text = school.name
                }
            }
        }
    }
}
