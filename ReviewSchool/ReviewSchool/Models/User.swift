//
//  User.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import Foundation
import Firebase

class User: Codable {
    static let defaultAvatar = "https://firebasestorage.googleapis.com/v0/b/school-review-c1bb6.appspot.com/o/images%2Fuser.png?alt=media&token=4ae68768-1018-422b-aa1b-a7f1d59dab49"
    var uid:String
    var email:String?
    var username:String
    var avatar: String
    var dateCreated: Int
    var chatSchool:String
    var chatMode:Bool
    
    init() {
        uid = UUID().uuidString
        username = "No Name"
        avatar = User.defaultAvatar
        dateCreated = Int(Date().timeIntervalSince1970)
        chatSchool = "All"
        chatMode = true
    }
    
    private enum CodingKeys: String, CodingKey {
        case uid
        case email
        case username
        case avatar
        case dateCreated
        case chatSchool
        case chatMode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(username, forKey: .username)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(chatSchool, forKey: .chatSchool)
        try container.encode(chatMode, forKey: .chatMode)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        avatar = try container.decode(String.self, forKey: .avatar)
        dateCreated = try container.decode(Int.self, forKey: .dateCreated)
        chatSchool = try container.decode(String.self, forKey: .chatSchool)
        chatMode = try container.decode(Bool.self, forKey: .chatMode)
    }
}

class UserModel:FirObjectModel<User> {
    static let shared = UserModel()
    
    private override init(){
        super.init()
        collection = Firestore.firestore().collection("user")
    }
    
    func save(user: User, completion: ((Error?)->())?) {
        save(documentID: user.uid, object: user, completion: completion)
    }
    
    func cleanListener() {
        if let user = Auth.shared.currentUser {
            Firestore.firestore().collection("chat").document("room").collection(user.chatSchool).document(user.uid).delete()
        }
    }
}
