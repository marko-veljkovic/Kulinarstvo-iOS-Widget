//
//  AuthenticationService.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 24.4.23.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthenticationService {
    
    init() {
        
    }
    
    static func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        if Auth.auth().currentUser != nil {
            self.singOut()
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func singUp(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    static func singOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            //TODO: Handle error
            print(error.localizedDescription)
        }
    }
}
