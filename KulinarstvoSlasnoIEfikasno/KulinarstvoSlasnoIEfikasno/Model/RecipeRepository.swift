//
//  RecipeRepository.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 17.4.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class RecipeRepository {
    static let shared = RecipeRepository()
    
    private let store = Firestore.firestore()
    private let path = "recipes"
    
    var recipes: [Recipe] = [] {
        didSet {
            Datafeed.shared.recipeModel.delegate?.recipeModelDidChange(recipes: self.recipes)
        }
    }
    
    private init() {
        
    }
    
    func getRecipes() {
        self.store.collection(self.path).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Get recipes request error: \(error)")
                return
            }
            
            self.recipes = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Recipe.self)
            } ?? []
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        do {
            _ = try self.store.collection(self.path).addDocument(from: recipe)
        } catch {
            fatalError("Unable to add recipe: \(error.localizedDescription)")
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        guard let recipeID = recipe.id else {
            return
        }
        do {
            try self.store.collection(self.path).document(recipeID).setData(from: recipe)
        } catch {
            fatalError("Unable to update recipe: \(error.localizedDescription)")
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        guard let recipeID = recipe.id else {
            return
        }
        self.store.collection(self.path).document(recipeID).delete { error in
            print("Unable to delete recipe: \(error?.localizedDescription ?? "")")
        }
    }
}
