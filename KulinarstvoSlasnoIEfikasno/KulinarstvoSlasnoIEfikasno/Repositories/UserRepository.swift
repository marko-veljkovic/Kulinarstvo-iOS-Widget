//
//  UserRepository.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import Foundation

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LocalUser : Codable {
    @DocumentID var id: String?
    var favoriteRecipes: [String]?
    var uuid: String?
    var name: String?
    var surname: String?
    var nickname: String?
    var profilePictureUrl: String?
    
    init(favoriteRecipes: [String], uuid: String, name: String, surname: String, nickname: String , profilePictureUrl: String) {
        self.favoriteRecipes = favoriteRecipes
        self.uuid = uuid
        self.name = name
        self.surname = surname
        self.nickname = nickname
        self.profilePictureUrl = profilePictureUrl
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

    func addUser(_ userID: String, _ profilePictureUrl: String, _ name: String, _ surname: String, _ nickname: String) {
        self.store.collection(self.path).document(userID).setData([
            "uuid": userID,
            "favoriteRecipes": [],
            "profilePictureUrl": profilePictureUrl,
            "name": name,
            "surname": surname,
            "nickname": nickname
        ]) { error in
            if let error = error {
                print("Error while creating user: \(error)")
            }
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
    
    func deleteUser(_ userID: String) {
        self.store.collection(self.path).document(userID).delete { error in
            if let error = error {
                print("Unable to delete user: \(error.localizedDescription)")
                return
            }
        }
    }
}
