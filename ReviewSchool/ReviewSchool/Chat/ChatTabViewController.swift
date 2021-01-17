//
//  ChatTabViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit
import Firebase

class ChatTabViewController: UIViewController {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    var waitingCollection:CollectionReference?
    let currentUser = Auth.shared.currentUser!
    var waittingListener:ListenerRegistration?
    
    var isWaiting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waitingCollection = Firestore.firestore().collection("chat").document("room")
            .collection(currentUser.chatSchool)
        setupViews()
    }
    
    func setupViews(){
        headerView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 10)
        messageView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        chatButton.rounded(borderWidth: 0, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 5)
        
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.textAlignment = .center
        headerLabel.text = ""
        indicatorView.hidesWhenStopped = true
        indicatorView.stopAnimating()
    }
    
    @IBAction func chatButtonClick(_ sender: Any) {
        if isWaiting {
            cancel()
            return;
        }
        findChatRoom()
    }
    
    func findChatRoom(){
        isWaiting = true
        indicatorView.startAnimating()
        headerLabel.text = "Chúng tôi đang tìm kiếm bạn chat cho bạn"
        chatButton.setTitle("Huỷ tìm kiếm", for: .normal)
        waitingCollection?.getDocuments(completion: {[weak self](query, error) in
            if let docs = query?.documents {
                for doc in docs {
                    let data = doc.data()
                    if let uid = data["uid"] as? String, let peer = data["peer"] as? String, peer == "" {
                        DispatchQueue.main.async {
                            self?.connect(peerID: uid)
                        }
                        return
                    }
                }
            }
            self?.wait()
        })
    }
    
    func connect(peerID:String){
        waittingListener?.remove()
        waitingCollection?.document(peerID).updateData([
            "peer": currentUser.uid
        ]);
        
        indicatorView.stopAnimating()
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController")
            as? ChatRoomViewController else {
            return
        }
        vc.peerID = peerID
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func wait(){
        waitingCollection?.document(currentUser.uid).setData([
            "uid": currentUser.uid,
            "peer": ""
        ]);
        
        waittingListener = waitingCollection?.document(currentUser.uid).addSnapshotListener({ [weak self] (doc, error) in
            if let data = doc?.data() {
                if let peer = data["peer"] as? String, peer != "" {
                    DispatchQueue.main.async {
                        self?.connect(peerID: peer)
                    }
                }
            }
        })
    }
    
    func cancel(){
        isWaiting = false
        headerLabel.text = "";
        chatButton.setTitle("Vào chat ngay", for: .normal)
        indicatorView.stopAnimating()
        waitingCollection?.document(currentUser.uid).delete()
    }
    
}
