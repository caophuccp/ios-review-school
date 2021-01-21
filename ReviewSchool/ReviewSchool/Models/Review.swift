//
//  Review.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import Foundation
import Firebase

class Review: Codable {
    var id:String
    var userID:String
    var schoolID:String
    var star:Int
    var content:String
    var dateCreated:Int
    var dateCreatedString:String
    var image:String
    
    init(userID:String, schoolID:String, star:Int) {
        self.id = UUID().uuidString
        self.userID = userID
        self.schoolID = schoolID
        self.star = star
        self.content = ""
        self.dateCreated = Int(Date().timeIntervalSince1970)
        self.image = "https://cdn.pixabay.com/photo/2013/02/21/19/06/drink-84533_1280.jpg"
        self.dateCreatedString = ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userID
        case schoolID
        case star
        case content
        case dateCreated
        case image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userID, forKey: .userID)
        try container.encode(schoolID, forKey: .schoolID)
        try container.encode(star, forKey: .star)
        try container.encode(content, forKey: .content)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(image, forKey: .image)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userID = try container.decode(String.self, forKey: .userID)
        schoolID = try container.decode(String.self, forKey: .schoolID)
        star = try container.decode(Int.self, forKey: .star)
        content = try container.decode(String.self, forKey: .content)
        dateCreated = try container.decode(Int.self, forKey: .dateCreated)
        let date = Date(timeIntervalSince1970: TimeInterval(dateCreated))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateCreatedString = dateFormatter.string(from: date)
        image = try container.decode(String.self, forKey: .image)
    }
}


class ReviewModel:FirObjectModel<Review> {
    static let shared = ReviewModel()
    private override init(){
        super.init()
        self.collection = Firestore.firestore().collection("review")
    }
    func save(review: Review, completion: ((Error?)->())?) {
        self.save(documentID: review.id, object: review, completion: completion)
    }
    
    func getAll(byUserID userID:String, completion: (([Review]?, Error?)->())?){
        collection?.whereField("userID", isEqualTo: userID).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            let all = querySnapshot?.documents.compactMap({try? $0.data(as: Review.self)})
            completion?(all, nil)
        })
    }
    
    func getAll(bySchoolID schoolID:String, completion: (([Review]?, Error?)->())?){
        collection?.whereField("schoolID", isEqualTo: schoolID).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            let all = querySnapshot?.documents.compactMap({try? $0.data(as: Review.self)})
            completion?(all, nil)
        })
    }
    
    func getAll(orderBy field:String, completion: (([Review]?, Error?) ->())?) {
        collection?.order(by: field).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            let all = querySnapshot?.documents.compactMap({try? $0.data(as: Review.self)})
            completion?(all, nil)
        })
    }
}
