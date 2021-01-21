//
//  RatingView.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import UIKit

class RatingView:UIStackView {
    var star = 0 {
        didSet {
            reload()
        }
    }
    let yellowStar = UIImage(named: "star-4")
    let outlineStar = UIImage(named: "star-3")
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        self.isUserInteractionEnabled = false
        self.distribution = .equalCentering
        self.axis = .horizontal
        for i in 1...5 {
            let button = UIButton()
            button.setImage(yellowStar, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview(button)
            button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.15).isActive = true
            button.tag = i
            button.addTarget(self, action: #selector(rate(_:)), for: .touchUpInside)
        }
    }
    
    @objc func rate(_ sender:UIButton) {
        star = sender.tag
    }
    
    func reload(){
        for i in 0..<star {
            if let star = starButton(at: i) {
                star.setImage(yellowStar, for: .normal)
            }
        }
        
        if (star < 5) {
            for i in star..<5 {
                if let star = starButton(at: i) {
                    star.setImage(outlineStar, for: .normal)
                }
            }
        }
    }
    
    func starButton(at index:Int) -> UIButton? {
        if index < 0 || index >= self.arrangedSubviews.count {
            return nil
        }
        return arrangedSubviews[index] as? UIButton
    }
}
