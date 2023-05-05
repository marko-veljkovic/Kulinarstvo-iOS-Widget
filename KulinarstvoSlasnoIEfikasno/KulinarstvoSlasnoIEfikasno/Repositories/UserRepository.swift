//
//  UserRepository.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23..
//

import Foundation

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LocalUser : Codable {
    @DocumentID var id: String?
    var favoriteRecipes: [String]?
    var uuid: String?
    
    init(favoriteRecipes: [String], uuid: String) {
        self.favoriteRecipes = favoriteRecipes
        self.uuid = uuid
    }
}

class UserRepository {
    static let shared = UserRepository()
    
    private let store = Firestore.firestore()
    private let path = "users"
    
    var users: [LocalUser] = []
    var currentUser: LocalUser? = nil {
        didSet {
            Datafeed.shared.currentUser = currentUser
        }
    }
    
    private init() {
    }
    
    func getCurrentUser(uuid: String) {
        self.store.collection(self.path).document(uuid).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Get users request error: \(error)")
                return
            }
            
            do {
                try self.currentUser = querySnapshot?.data(as: LocalUser.self)
            } catch {
                fatalError("Unable to get user: \(error.localizedDescription)")
            }
        }
    }

    func addUser(_ user: LocalUser) {
        do {
            _ = try self.store.collection(self.path).addDocument(from: user)
        } catch {
            fatalError("Unable to add user: \(error.localizedDescription)")
        }
    }
    
    func updateUser(_ user: LocalUser) {
        guard let userID = user.id else {
            return
        }
        do {
            try self.store.collection(self.path).document(userID).setData(from: user)
        } catch {
            fatalError("Unable to update user: \(error.localizedDescription)")
        }
    }
    
    func deleteUser(_ user: LocalUser) {
        guard let userID = user.id else {
            return
        }
        self.store.collection(self.path).document(userID).delete { error in
            print("Unable to delete user: \(error?.localizedDescription ?? "")")
        }
    }
}
