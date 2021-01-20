//
//  School.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import Foundation
import Firebase
class School: Codable {
    static let defaultAvatar = "https://firebasestorage.googleapis.com/v0/b/school-review-c1bb6.appspot.com/o/images%2Fschool.png?alt=media&token=09e1d954-8080-4061-a5da-b34d8a84ef01"
    var id:String
    var name:String
    var address:String
    var avatar:String
    
    init(id: String, name: String, address:String) {
        self.id = id
        self.name = name
        self.address = address
        self.avatar = School.defaultAvatar
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case avatar
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(avatar, forKey: .avatar)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        avatar = try container.decode(String.self, forKey: .avatar)
    }
}


class SchoolModel:FirObjectModel<School> {
    static let shared = SchoolModel()
    private override init(){
        super.init()
        self.collection = Firestore.firestore().collection("school")
    }
    func save(school: School, completion: ((Error?)->())?) {
        self.save(documentID: school.id, object: school, completion: completion)
    }
//
//    func peganition(){
//        let first = db.collection("cities")
//            .order(by: "population")
//            .limit(to: 25)
//
//        first.addSnapshotListener { (snapshot, error) in
//            guard let snapshot = snapshot else {
//                print("Error retreving cities: \(error.debugDescription)")
//                return
//            }
//
//            guard let lastSnapshot = snapshot.documents.last else {
//                return
//            }
//            let next = db.collection("cities")
//                .order(by: "population")
//                .start(afterDocument: lastSnapshot)
//        }
//    }
}
