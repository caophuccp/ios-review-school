//
//  FirebaseStorage.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 18/01/2021.
//

import Foundation
import Firebase

class FirebaseStorage {
    static let shared = FirebaseStorage()
    private init(){}
    let storageReference = Storage.storage().reference()
    
    func putFile(imageURL:URL, completion: ((URL?, Error?)->())?){
        let imageRef = storageReference.child("images").child(UUID().uuidString)
        let _ = imageRef.putFile(from: imageURL, metadata: nil){ (url, err) in
            imageRef.downloadURL { (url, err) in
                completion?(url, err)
            }
        }
    }
}
