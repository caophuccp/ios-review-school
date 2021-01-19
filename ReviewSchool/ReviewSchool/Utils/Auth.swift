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
    
    func signIn(email:String, password:String, completion: ((User?, Error?) -> Void)?) {
        firebaseAuth.signIn(withEmail: email, password: password) {(authResult, error) in
            if let err = error {
                print("signIn: " + err.localizedDescription)
                return
            }
            
            if let fireUser = authResult?.user {
                UserModel.shared.get(documentID: fireUser.uid, completion: { (user, error) in
                    self.currentUser = user
                    completion?(user, error)
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
    
    func changePassword(old: String, new: String, completion: ((Error?) -> ())?) {
        if let firebaseUser = firebaseAuth.currentUser {
            let credential = EmailAuthProvider.credential(withEmail: firebaseUser.email ?? "", password: old)
            firebaseUser.reauthenticate(with: credential) { (auth, error) in
                firebaseUser.updatePassword(to: new, completion: completion)
            }
        } else {
            completion?(AuthError.userNil)
        }
    }
    
    enum AuthError:Error {
        case userNil
    }
    
    var currentUser:User?
}
