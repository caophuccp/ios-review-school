//
//  AdminSchoolCellView.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit

class AdminSchoolCellView:UITableViewCell {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func setupViews(school:School){
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.6
        addressLabel.numberOfLines = 2

        nameLabel.text = school.name
        addressLabel.text = school.address
        
        guard let url = URL(string: school.avatar) else {
            return
        }
        NetworkImage.shared.download(url: url) { [weak self](image) in
            DispatchQueue.main.async {
                self?.avatarView?.image = image
            }
        }
    }
}
