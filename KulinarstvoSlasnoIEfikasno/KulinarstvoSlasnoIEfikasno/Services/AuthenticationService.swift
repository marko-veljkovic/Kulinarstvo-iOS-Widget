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
    
    static var userIdBeforeDeletion: String = ""
    
    init() {
        
    }
    
    static func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        if let currUser = Auth.auth().currentUser {
            if currUser.isAnonymous {
                // Delete anonymous user
                currUser.delete()
            }
            else {
                self.singOut()
            }
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func singUp(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        // Delete anonymous user
        if let currUser = Auth.auth().currentUser, currUser.isAnonymous {
            currUser.delete()
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    static func singOut() {
        do {
            try Auth.auth().signOut()
            self.signInAnonymous()
            // Sign in anonymous user
        } catch {
            //TODO: Handle error
            print(error.localizedDescription)
        }
    }
    
    static func deleteUser() {
        Auth.auth().currentUser?.delete() { error in
            if let error = error {
                print("Error while deelting user \(error.localizedDescription)")
                return
            }
            if let currUser = Datafeed.shared.currentUser {
                self.userIdBeforeDeletion = (currUser.id ?? "")
                if Auth.auth().currentUser == nil {
                    self.signInAnonymous(true)
                }
            }
        }
    }
    
    static func signInAnonymous(_ shouldDeleteUser: Bool = false) {
        Auth.auth().signInAnonymously() { user, error in
            if shouldDeleteUser {
                Datafeed.shared.userRepository.deleteUser(self.userIdBeforeDeletion)
            }
        }
    }
}
