//
//  LazyQuery.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 21/01/2021.
//

import Foundation
import Firebase

class LazyQuery<T:Codable> {
    let collection:CollectionReference
    var lastDocument:DocumentSnapshot?
    var isLoading = false
    var isEmpty = false
    var orderBy:String
    let queue = DispatchQueue(label: "syncqueue")
    let limit = 20
    var descending:Bool
    
    init(collection:CollectionReference, orderBy:String, descending:Bool = false) {
        self.collection = collection
        self.orderBy = orderBy
        self.descending = descending
    }
    
    func reset(){
        isLoading = false
        isEmpty = false
        lastDocument = nil
    }
    
    func getDataSync(completion: (([T]?, Error?) -> ())?){
        queue.sync {
            self.getData(completion: completion)
        }
    }
    
    func getData(completion: (([T]?, Error?) -> ())?){
        if isLoading {
            return
        }
        if isEmpty {
            completion?(nil, nil)
            return
        }
        isLoading = true
        if let lastDocument = lastDocument {
            collection.order(by: orderBy, descending: descending)
                .start(afterDocument: lastDocument)
                .limit(to: limit)
                .getDocuments(completion: { (querySnapshot, error) in
                    self.isLoading = false
                    if error != nil {
                        completion?(nil, error)
                        return
                    }
                    if let last = querySnapshot?.documents.last {
                        self.lastDocument = last
                        let all = querySnapshot?.documents.compactMap({try? $0.data(as: T.self)})
                        completion?(all, nil)
                    } else {
                        self.isEmpty = true
                    }
                })
        } else {
            collection.order(by: orderBy, descending: descending)
                .limit(to: limit)
                .getDocuments(completion: { (querySnapshot, error) in
                    self.isLoading = false
                    if error != nil {
                        completion?(nil, error)
                        return
                    }
                    if let last = querySnapshot?.documents.last {
                        self.lastDocument = last
                        let all = querySnapshot?.documents.compactMap({try? $0.data(as: T.self)})
                        completion?(all, nil)
                    } else {
                        self.isEmpty = true
                    }
                })
        }
    }
}

class LazyQueryFilter<T:Codable>:LazyQuery<T>{
    let key:String
    
    init(collection: CollectionReference, orderBy: String, key:String, descending:Bool = false) {
        self.key = key.trimmingCharacters(in: .whitespaces)
        super.init(collection: collection, orderBy: orderBy, descending: descending)
    }
    override func getData(completion: (([T]?, Error?) -> ())?){
      
        if isLoading {
            return
        }
        if isEmpty {
            completion?(nil, nil)
            return
        }
        isLoading = true
        if let lastDocument = lastDocument {
            collection
                .order(by: orderBy, descending: descending)
                .start(at: [key])
                .end(at: [(key + "\u{F8FF}")])
                .start(afterDocument: lastDocument)
                .limit(to: limit)
                .getDocuments(completion: { (querySnapshot, error) in
                    self.isLoading = false
                    if error != nil {
                        completion?(nil, error)
                        return
                    }
                    if let last = querySnapshot?.documents.last {
                        self.lastDocument = last
                        let all = querySnapshot?.documents.compactMap({try? $0.data(as: T.self)})
                        completion?(all, nil)
                    } else {
                        self.isEmpty = true
                    }
                })
        } else {
            collection.order(by: orderBy, descending: descending)
                .start(at: [key])
                .end(at: [(key + "\u{F8FF}")])
                .limit(to: limit)
                .getDocuments(completion: { (querySnapshot, error) in
                    self.isLoading = false
                    if error != nil {
                        completion?(nil, error)
                        return
                    }
                    if let last = querySnapshot?.documents.last {
                        self.lastDocument = last
                        let all = querySnapshot?.documents.compactMap({try? $0.data(as: T.self)})
                        completion?(all, nil)
                    } else {
                        self.isEmpty = true
                    }
                })
        }
    }
}
