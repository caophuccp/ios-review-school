//
//  School.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import Foundation
import Firebase
class School: Codable {
    var id:String
    var name:String
    var address:String
    
    init(name: String, address:String) {
        self.id = UUID().uuidString
        self.name = name
        self.address = address
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
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
}
