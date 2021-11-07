//
//  RecipeModel.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import Foundation
import SwiftUI

public struct Recipe : Codable {
//        var id = UUID()
    var name: String
    var prepTime: Int // In minutes
    
    var ingredients: [String]
    var steps: [String]
    
    var isFavorite: Bool?
    
    var url: URL? {
        return URL(string: "kulinarstvoslasnoiefikasno://" + name)
    }
    
    var imageName: String {
        return name
    }
}

protocol RecipeModelDelegate : AnyObject {
    func recipeModelDidChange(recipes: [Recipe])
}

class RecipeModel {
    
    weak var delegate: RecipeModelDelegate?

    static let testData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [
            "3 jaja", "1 paradajz"
        ], steps: [
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Sipati u tiganj i prziti"
        ]),
        Recipe(name: "Spagete karbonare", prepTime: 45, ingredients: [], steps: []),
        Recipe(name: "Pirinac", prepTime: 20,
               ingredients: ["Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac", "Pirinac"],
               steps: [ "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac", "Dodati pirinac"]),
        Recipe(name: "Mesano povrce", prepTime: 25, ingredients: [], steps: []),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: [], steps: [])
    ]

    static var myTestData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [
            "2 jaja", "1.5 paradajz"
        ], steps: [
            "Izmutiti jaja", "Dodati sitno seckan paradajz", "Sipati u tiganj i prziti"
        ]),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: ["2 parceta tost hleba", "Pecenica", "Kackavalj"], steps: [
            "Uzeti jedno parce hleba", "Staviti pecenicu na njega", "Staviti kackavalj preko", "Staviti drugo parce hleba"
        ])
    ]
    
    private var recipes: [Recipe] = []
    var isLoaded = false
    
    func loadFile() {
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = dir?.appendingPathComponent("RecipesData.json")
            
            //If file exist in document directory
            if let data = try? Data(contentsOf: fileURL!) {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let recipes = jsonResult["recipes"] as? [Any] {
                    for recipe in recipes {
                        self.recipes.append(self.parseRecipe(recipe: recipe))
                    }
                }
                self.delegate?.recipeModelDidChange(recipes: self.recipes)
                self.isLoaded = true
            }
            //If file exist in local
            else if let path = Bundle.main.path(forResource: "RecipesData", ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let recipes = jsonResult["recipes"] as? [Any] {
                    for recipe in recipes {
                        self.recipes.append(self.parseRecipe(recipe: recipe))
                    }
                }
                self.delegate?.recipeModelDidChange(recipes: self.recipes)
                self.isLoaded = true
            }
        } catch {
            print("File could not be loaded")
        }
    }
    
    func parseRecipe(recipe: Any) -> Recipe {
        guard let r = recipe as? [String:Any] else {
            return Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false)
        }
        
        var rec = Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false)
        for recipeKey in r.keys {
            switch recipeKey {
            case "name":
                rec.name = (r["name"] as? String ?? "")
            case "prepTime":
                rec.prepTime = (r["prepTime"] as? Int ?? 0)
            case "ingredients":
                rec.ingredients = (r["ingredients"] as? [String] ?? [])
            case "steps":
                rec.steps = (r["steps"] as? [String] ?? [])
            case "isFavorite":
                rec.isFavorite = (r["isFavorite"] as? Bool ?? false)
            default:
                ()
            }
        }
        return rec
    }
}

protocol DatafeedDelegate : AnyObject {
    func recipesDataParsed()
}

class Datafeed {
    
    static let shared = Datafeed()
    
    private init() {
//        self.recipes = []
    }
    
    lazy var recipeModel: RecipeModel = {
        var model = RecipeModel()
        model.delegate = self
        return model
    }()
    
    weak var delegate: DatafeedDelegate?
    
    var recipes: [Recipe] = [] {
        didSet {
            self.delegate?.recipesDataParsed()
        }
    }
    
    var favRecipes: [Recipe] {
        get {
            let filtered = self.recipes.filter {
                $0.isFavorite ?? false
            }
            return filtered
        }
    }
}

extension Datafeed : RecipeModelDelegate {
    func recipeModelDidChange(recipes: [Recipe]) {
        self.recipes = recipes
    }
    
}
