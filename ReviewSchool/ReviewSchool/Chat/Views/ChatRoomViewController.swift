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
    
    var messages = [MessageObject.startMessage()]
    
    let db = Firestore.firestore()
    let storageReference = Storage.storage().reference()
    let user = Auth.shared.currentUser!
    var peerID = "bfZeRPepF8QjmfttLuSrEXgSoq52"
    var groupChatID = ""
    var messageListener:ListenerRegistration?
    
    var userAvatar = UIImage(named: "user")
    var peerAvatar = UIImage(named: "user")
    var messageCollection:CollectionReference?
    var firstTimeGetMsg = true
    var isStopped = false
    var endChatListener:ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if user.uid.hash < peerID.hash {
            groupChatID = user.uid + peerID
        } else {
            groupChatID = peerID + user.uid
        }
        messageCollection = db.collection("chat").document("messages").collection(groupChatID)
        messageCollection?.document("endchat").setData(["end":false])
        startChat()
        endChatListener = messageCollection?.document("endchat").addSnapshotListener({[weak self] (document, error) in
            if let doc = document?.data(), let end = doc["end"] as? Bool {
                if end {
                    self?.endChat()
                }
            }
        });
        registerForKeyboardNotifications()
        
        UserModel.shared.get(documentID: peerID) {[weak self](user, error) in
            if let avatar = user?.avatar, let url = URL(string: avatar) {
                NetworkImage.shared.download(url: url){ image in
                    self?.peerAvatar = image
                    DispatchQueue.main.async {
                        self?.messageTableView.reloadData()
                    }
                }
            }
        }
        if let url = URL(string: user.avatar) {
            NetworkImage.shared.download(url: url){ [weak self] image in
                self?.userAvatar = image
                DispatchQueue.main.async {
                    self?.messageTableView.reloadData()
                }
            }
        }
    }
    
    func endChat(){
        isStopped = true
        messageListener?.remove()
        messages.insert(MessageObject.endMessage(), at: 0)
        
        DispatchQueue.main.async {
            self.inputTextView.isEditable = false
            self.messageTableView.reloadData()
        }
    }
    
    func deleteMessageCollection(){
        if let collection = messageCollection {
            deleteCollection(collection: collection)
        }
    }
    
    func deleteCollection(collection: CollectionReference) {
        collection.getDocuments {(docset, error) in
            let batch = collection.firestore.batch()
            docset?.documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit()
        }
    }
    
    func setupViews(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 100
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.separatorStyle = .none
        messageTableView.transform = CGAffineTransform(rotationAngle: -.pi)
        
        
        inputTextView.delegate = self
        inputTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        inputTextView.autocorrectionType = .no
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 10
        inputTextView.layer.borderWidth = 1.5
        inputTextView.layer.borderColor = #colorLiteral(red: 0.2019728422, green: 0.5961080194, blue: 0.6889011264, alpha: 1)
        inputTextView.text = "Write a message..."
        inputTextView.textColor = .darkGray
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    deinit {
        if (!isStopped) {
            messageListener?.remove()
            deregisterFromKeyboardNotifications()
            messageCollection?.document("endchat").setData(["end":true])
        } else {
            deleteMessageCollection()
        }
    }
    
    func startChat(){
        getData()
    }
    
    func getData(){
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
            
            let messages = documents.compactMap({try? $0.data(as: MessageObject.self)})
            if sSelf.firstTimeGetMsg{
                sSelf.firstTimeGetMsg = false
                if !messages.isEmpty {
                    sSelf.deleteMessageCollection()
                    return
                }
            }
            
            if !messages.isEmpty && !sSelf.isStopped{
                sSelf.messages = messages
                sSelf.messages.sort(by: {$0.timestamp > $1.timestamp})
                sSelf.messageTableView.reloadData()
    //            sSelf.messageTableView.scrollToBottom()
                sSelf.messageTableView.scrollToTop()
            }
        }
    }
    func sendMessage(message:MessageObject) {
        do {
            let _ = try messageCollection?.addDocument(from: message)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func sendImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
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
            inputTVHeightContraint.constant = 40
            isMessageEmpty = true
            sendMessage(message: message)
        }
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        if message.ownerID == "system" {
            cellID = "SystemCellID"
        } else {
            if message.contentType == .text {
                cellID = message.ownerID == peerID ? "LeftTextCellID" : "RightTextCellID"
            } else {
                cellID = message.ownerID == peerID ? "LeftImageCellID" : "RightImageCellID"
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MessageViewCell
        cell.selectionStyle = .none
        let avatar = message.ownerID == peerID ? peerAvatar : userAvatar
        cell.setup(message: messages[indexPath.row], avatar: avatar)
        cell.transform = CGAffineTransform(rotationAngle: .pi)
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
//        messageTableView.scrollToBottom()
        messageTableView.scrollToTop()
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        inputViewBottomConstraint.constant = keyboardSize.height
//        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
//            self.view.layoutIfNeeded()
//        } completion: { (_) in
//
//        }
//
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        inputViewBottomConstraint.constant = 5
//        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
//            self.view.layoutIfNeeded()
//        } completion: { (_) in
//
//        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        isMessageEmpty = false
        let heightConstant = inputTVHeightContraint.constant
        let contentHeight = textView.contentSize.height
        if abs(contentHeight - heightConstant) > 5 && contentHeight < 150 && contentHeight > 40 {
            inputTVHeightContraint.constant = contentHeight
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isMessageEmpty {
            inputTextView.textColor = .darkText
            inputTextView.text = ""
            inputTVHeightContraint.constant = 40
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
        if let url = info[.imageURL] as? URL{
            sendImage(imageURL: url)
        }
    }
    
    func sendImage(imageURL:URL){
        messages.insert(MessageObject(content: "", type: .photo, ownerID: user.uid), at: 0)
        messageTableView.reloadData()
        FirebaseStorage.shared.putFile(imageURL: imageURL) { [weak self](url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url = url {
                self?.sendImage(url: url)
            }
        }
    }
    
    func sendImage(url:URL) {
        let message = MessageObject()
        message.content = url.absoluteString
        message.contentType = .photo
        message.ownerID = user.uid
        
        sendMessage(message: message)
    }
}
