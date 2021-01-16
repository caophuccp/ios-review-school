//
//  MessageViewCell.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class MessageViewCell:UITableViewCell {
    static var imagesCache = NSCache<NSString, UIImage>()
    func setup(message:MessageObject, avatar:UIImage?) {
        
    }
}

class TextMessageViewCell:MessageViewCell {
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var avatarImageView: UIImageView?
    
    let tx:String = {
        let numText = Int.random(in: 10...500)
        return String((1...numText).map{(_)->Character in Character(Unicode.Scalar(Int.random(in: 65...80))!)})
    }()
    
    override func setup(message:MessageObject, avatar:UIImage?){
        avatarImageView?.image = avatar
        textView?.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView?.layer.masksToBounds = true
        textView?.layer.cornerRadius = 10
        textView?.text = message.content
        self.avatarImageView?.layer.masksToBounds = true
        self.avatarImageView?.layer.cornerRadius = 15
        self.avatarImageView?.contentMode = .scaleAspectFill
    }
}

class ImageMessageViewCell:MessageViewCell {
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var imageAspectConstraint: NSLayoutConstraint?
    @IBOutlet weak var avatarImageView: UIImageView?
    
    override func setup(message:MessageObject, avatar:UIImage?){
        self.msgImageView.contentMode = .scaleAspectFit
//        self.msgImageView.backgroundColor = .systemRed
        self.msgImageView.layer.masksToBounds = true
        self.msgImageView.layer.cornerRadius = 10
        self.avatarImageView?.layer.masksToBounds = true
        self.avatarImageView?.layer.cornerRadius = 15
        self.avatarImageView?.contentMode = .scaleAspectFill
        avatarImageView?.image = avatar
        guard let urlStr = message.content, let url = URL(string: urlStr) else {
            return
        }
        NetworkImage.shared.download(url: url) { [weak self](image) in
            if let image = image {
                DispatchQueue.main.async{
                    self?.setImage(image: image)
                }
            }
        }
    }
    
    func setImage(image:UIImage) {
        if imageAspectConstraint != nil {
            let aspect = image.size.width/image.size.height
            imageAspectConstraint?.isActive = false
            imageAspectConstraint = self.msgImageView.widthAnchor.constraint(equalTo: msgImageView.heightAnchor, multiplier: aspect)
            imageAspectConstraint?.priority = UILayoutPriority(rawValue: 999)
            imageAspectConstraint?.isActive = true
        }
        self.msgImageView.image = image
        self.layoutIfNeeded()
    }
}

class SystemMessageViewCell:MessageViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    override func setup(message: MessageObject, avatar: UIImage?) {
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 10
        textView.text = message.content
    }
}
