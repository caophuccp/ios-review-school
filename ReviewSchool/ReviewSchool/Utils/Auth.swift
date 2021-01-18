//
//  FirCollection.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 17/01/2021.
//

import Foundation
import Firebase

class Auth {
    static let shared = Auth()
    private init(){}
    
    let firebaseAuth = Firebase.Auth.auth()
    
    func signIn(email:String, password:String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        firebaseAuth.signIn(withEmail: email, password: password) {[weak self](authResult, error) in
            if let err = error {
                print("signIn" + err.localizedDescription)
                return
            }
            
            if let user = authResult?.user {
                UserModel.shared.get(documentID: user.uid, completion: { (user, error) in
                    self?.currentUser = user
                })
            }
        }
    }
    
    func checkAuthState(completion: ((User?) -> Void)?){
        if let firUser = firebaseAuth.currentUser {
            UserModel.shared.get(documentID: firUser.uid) { [weak self] (user, error) in
                if let err = error {
                    print("checkAuthState" + err.localizedDescription)
                }
                if user == nil {
                    try? self?.firebaseAuth.signOut()
                }
                self?.currentUser = user
                completion?(user)
            }
        }
    }
    
    func signOut(){
        try? firebaseAuth.signOut()
    }
    
    var currentUser:User?
}
