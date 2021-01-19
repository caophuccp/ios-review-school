//
//  BaseModel.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import Foundation
import Firebase

class FirObjectModel<T:Codable> {
    
    var collection:CollectionReference?
    
    func get(documentID:String, completion: ((T?, Error?) -> Void)?){
        collection?.document(documentID).getDocument(completion: { (documentSnapshot, error) in
            let object = try? documentSnapshot?.data(as: T.self)
            completion?(object, error)
        })
    }
    
    func getAll(completion: (([T]?, Error?) -> Void)?){
        collection?.getDocuments { (querySnapshot, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            let all = querySnapshot?.documents.compactMap({try? $0.data(as: T.self)})
            completion?(all, nil)
        }
    }
    
    func save(documentID: String, object: T, completion: ((Error?)->())?) {
        try? collection?.document(documentID).setData(from: object) { (error) in
            completion?(error)
        }
    }
    
    func addDocument(object:T, completion: ((Error?)->())?) {
        let _ = try? collection?.addDocument(from: object){ (error) in
            completion?(error)
        }
    }
    
    func addSnapshotListener(_ listener:@escaping FIRQuerySnapshotBlock){
        collection?.addSnapshotListener(listener)
    }
    
    func updateData(documentID:String, fields:[AnyHashable:Any], completion:((Error?)->Void)?) {
        collection?.document(documentID).updateData(fields, completion: completion)
    }
}
