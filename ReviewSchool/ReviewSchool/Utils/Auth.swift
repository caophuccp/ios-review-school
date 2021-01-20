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
    
    func createUser(user:User, password:String, completion: ((User?, Error?) -> ())?) {
        firebaseAuth.createUser(withEmail: user.email ?? "", password: password) { (auth, error) in
            if let error = error {
                completion?(nil, error)
                print(error.localizedDescription)
                return
            }
            
            if let auth = auth {
                let fireUser = auth.user
                user.uid = fireUser.uid
                UserModel.shared.save(user: user) { (error) in
                    if error == nil {
                        self.currentUser = user
                        completion?(user, nil)
                        return
                    }
                    self.deleteCurrentUser()
                }
            }
            completion?(nil, nil)
        }
    }
    
    func deleteCurrentUser(){
        let firebaseUser = firebaseAuth.currentUser
        firebaseUser?.delete();
        signOut();
    }
    
    func signIn(email:String, password:String, completion: ((User?, Error?) -> Void)?) {
        firebaseAuth.signIn(withEmail: email, password: password) {(authResult, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            
            if let fireUser = authResult?.user {
                UserModel.shared.get(documentID: fireUser.uid, completion: { (user, error) in
                    self.currentUser = user
                    completion?(user, error)
                })
                return
            }
            completion?(nil, nil)
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
            completion?(AuthError.UserNil)
        }
    }
    
    func sendPasswordReset(email:String, completion:((Error?) -> Void)?){
        firebaseAuth.sendPasswordReset(withEmail: email, completion: completion)
    }
    
    enum AuthError:Error {
        case UserNil
    }
    
    var currentUser:User?
}
