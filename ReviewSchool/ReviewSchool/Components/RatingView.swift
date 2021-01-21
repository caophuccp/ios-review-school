//
//  RatingView.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class RatingView:UIStackView {
    var star = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        self.distribution = .equalCentering
        self.axis = .horizontal
        for _ in 1...5 {
            let view = UIImageView(image: UIImage(named: "star-4"))
            view.contentMode = .scaleAspectFit
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.18).isActive = true
        }
    }
}
