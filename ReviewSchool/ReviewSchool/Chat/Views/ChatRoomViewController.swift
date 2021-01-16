//
//  ChatRoomViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ChatRoomViewController: UIViewController {
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputTVHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    let indicatorView = UIActivityIndicatorView()
    
    var isMessageEmpty = true
    
    var messages = [MessageObject]()
    
    let db = Firestore.firestore()
    let storageReference = Storage.storage().reference()
    let user = Auth.auth().currentUser!
    var peerID = "bfZeRPepF8QjmfttLuSrEXgSoq52"
    var groupChatID = ""
    var messageListener:ListenerRegistration?
    
    let userAvatar = UIImage(named: "avt")
    let peerAvatar = UIImage(named: "avt")
    var messageCollection:CollectionReference?
    var imagesCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 100
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.separatorStyle = .none
        
        if user.uid == "bfZeRPepF8QjmfttLuSrEXgSoq52" {
            peerID = "ewkWfiWdpZXB66brRNLgtkQi8XF2"
        }
        
        if user.uid.hash < peerID.hash {
            groupChatID = user.uid + peerID
        } else {
            groupChatID = peerID + user.uid
        }
        messageCollection = db.collection("chat").document("message").collection(groupChatID)
        getData()
        
        inputTextView.delegate = self
        inputTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        inputTextView.autocorrectionType = .no
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 10
        inputTextView.layer.borderWidth = 1.5
        inputTextView.layer.borderColor = #colorLiteral(red: 0.2019728422, green: 0.5961080194, blue: 0.6889011264, alpha: 1)
        inputTextView.text = "Write a message..."
        inputTextView.textColor = .darkGray
        
        registerForKeyboardNotifications()
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    deinit {
        messageListener?.remove()
        deregisterFromKeyboardNotifications()
    }
    
    func getData(){
//        LocalData.messages { [weak self] (result) in
//            self?.messages = result
//            self?.messageTableView.reloadData()
//        }
        messageListener = messageCollection?.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let sSelf = self else {
                return
            }
            if let e = error {
                print(e.localizedDescription)
                return
            }
            guard let documents = querySnapshot?.documents else {
                return
            }
//            var messages = [MessageObject]()
//            documents.compactMap(<#T##transform: (QueryDocumentSnapshot) throws -> ElementOfResult?##(QueryDocumentSnapshot) throws -> ElementOfResult?#>)
//            for document in documents {
//                if let message = try? document.data(as: MessageObject.self) {
//                    messages.append(message)
//                }
//            }
            for document in documents {
                if let message = try? document.data(as: MessageObject.self) {
                    if !sSelf.messages.contains(where: {$0.id == message.id}) {
                        sSelf.messages.append(message)
                    }
                }
            }
            sSelf.messages.sort(by: {$0.timestamp < $1.timestamp})
            sSelf.messageTableView.reloadData()
            sSelf.messageTableView.scrollToBottom()
        }
    }
    
    @IBAction func sendImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func send(_ sender: Any) {
        if !isMessageEmpty && !inputTextView.text.isEmpty{
            let message = MessageObject()
            message.content = inputTextView.text
            message.contentType = .text
            message.ownerID = user.uid
            inputTextView.text = ""
            isMessageEmpty = true
            sendMessage(message: message)
        }
    }
    
    func sendMessage(message:MessageObject) {
        do {
            let _ = try messageCollection?.addDocument(from: message)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ChatRoomViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID:String
        let message = messages[indexPath.row]
        if message.contentType == .text {
            cellID = message.ownerID == peerID ? "LeftTextCellID" : "RightTextCellID"
        } else {
            cellID = message.ownerID == peerID ? "LeftImageCellID" : "RightImageCellID"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MessageViewCell
        cell.selectionStyle = .none
        let avatar = message.ownerID == peerID ? peerAvatar : userAvatar
        cell.setup(message: messages[indexPath.row], avatar: avatar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        inputTextView.resignFirstResponder()
    }
}

extension ChatRoomViewController: UITextViewDelegate {
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let info = notification.userInfo else {
            return
        }
        messageTableView.scrollToBottom()
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        inputViewBottomConstraint.constant = -keyboardSize.height
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
    

    @objc func keyboardWillHide(_ notification: NSNotification) {
        inputViewBottomConstraint.constant = 5
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        isMessageEmpty = false
        let heightConstant = inputTVHeightContraint.constant
        let contentHeight = textView.contentSize.height
        if abs(contentHeight - heightConstant) > 5 && contentHeight < 150 && contentHeight > 40 {
            inputTVHeightContraint.constant = textView.contentSize.height
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isMessageEmpty {
            inputTextView.textColor = .darkText
            inputTextView.text = ""
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if inputTextView.text == "" {
            inputTextView.text = "Write a message..."
            inputTextView.textColor = .darkGray
        } else {
            isMessageEmpty = false
        }
        return true
    }
}

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL, let image = info[.originalImage] as? UIImage{
            sendImage(imageURL: url, imageSize:image.size)
        }
    }
    
    func sendImage(imageURL:URL, imageSize:CGSize){
        print("Send Image: \(imageURL)")
        let imageRef = storageReference.child("images").child(UUID().uuidString)
        let _ = imageRef.putFile(from: imageURL, metadata: nil) { [weak self](metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            imageRef.downloadURL { (url, err) in
                if let url = url {
                    self?.sendImage(url: url, size: imageSize)
                }
            }
        }
    }
    
    func sendImage(url:URL, size:CGSize) {
        let message = MessageObject()
        message.content = url.absoluteString
        message.contentType = .photo
        message.ownerID = user.uid
    
        sendMessage(message: message)
    }
}
