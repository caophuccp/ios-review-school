//
//  Validator.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import Foundation

class Validator {
    class ValidationError {
        var error:Bool
        var message:String?
        
        init(error:Bool, message:String?) {
            self.error = error
            self.message = message
        }
    }
    
    private static let EmailRegex = "^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\\.[a-zA-Z]+$";
    private static let UsernameRegex = "^[ a-zA-Z0-9]+$";
    private static let PasswordRegex = "^(?=.*?[A-Z])(?=(.*[a-z])+)(?=(.*[\\d])+)(?=(.*[\\W])+)(?!.*\\s).{8,}$";
    
    private static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", EmailRegex)
    private static let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", UsernameRegex)
    private static let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", PasswordRegex)
    
    static func isValid(email: String) -> Bool{
        return emailPredicate.evaluate(with: email)
    }

    static func isValid(password: String) -> Bool {
        return passwordPredicate.evaluate(with: password)
    }

    static func isValid(username: String) -> Bool {
        return usernamePredicate.evaluate(with: username)
    }
}
