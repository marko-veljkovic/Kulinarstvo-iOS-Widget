//
//  RecipeModel.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import Foundation
import SwiftUI

public class Recipe : Codable {
//        var id = UUID()
    var name: String
    var prepTime: Int // In minutes
    
    var ingredients: [Ingredient]
    var steps: [String]
    
    var isFavorite: Bool?
    var isMyRecipe: Bool?
    
    var category: RecipeCategory?
    
    var stringIngredients: [String] {
        var stringIngredients: [String] = []
        for ingredient in self.ingredients {
            let stringIngredient = "\(ingredient.quantity) \(ingredient.measureUnit) \(ingredient.ingredient)"
            stringIngredients.append(stringIngredient)
        }
        return stringIngredients
    }
    
    var url: URL? {
        return URL(string: "kulinarstvoslasnoiefikasno://" + name.replacingOccurrences(of: " ", with: "_"))
    }
    
    var imageName: String {
        return name
    }
    
    init(name: String, prepTime: Int, ingredients: [Ingredient], steps: [String], isFavorite: Bool? = false, isMyRecipe: Bool? = false, category: RecipeCategory) {
        self.name = name
        self.prepTime = prepTime
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.isMyRecipe = isMyRecipe
        self.category = category
    }
}

public struct Ingredient : Codable {
    var quantity: Int
    var measureUnit: String
    var ingredient: String
    
    init(quantity: Int, measureUnit: String, ingredient: String) {
        self.quantity = quantity
        self.measureUnit = measureUnit
        self.ingredient = ingredient
    }
}

public enum RecipeCategory : Int, Codable, CaseIterable {
    case coldSideDish = 0, warmSideDish, mainDish, snack, drink, soup, dessert, salad, bread
}

protocol RecipeModelDelegate : AnyObject {
    func recipeModelDidChange(recipes: [Recipe])
}

class RecipeModel {
    
    weak var delegate: RecipeModelDelegate?

    static let testData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [
            Ingredient(quantity: 3, measureUnit: "komada", ingredient: "jaja"),
            Ingredient(quantity: 20, measureUnit: "grama", ingredient: "sira"),
            Ingredient(quantity: 1, measureUnit: "kasicica", ingredient: "persun")
        ], steps: [
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu"
        ], category: .warmSideDish),
        Recipe(name: "Spagete karbonara", prepTime: 45, ingredients: [], steps: [], category: .mainDish),
        Recipe(name: "Pirinac", prepTime: 20,
               ingredients: [],
               steps: [ "Oprati pirinac", "Dodati vodu", "Dodati zejtin", "Dodati so", "Kuvati 20ak minuta"], category: .warmSideDish),
        Recipe(name: "Mesano povrce", prepTime: 25, ingredients: [], steps: [], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: [], steps: [], category: .bread)
    ]

    static var myTestData = [
        Recipe(name: "Omlet", prepTime: 15, ingredients: [], steps: [
            "Izmutiti jaja", "Dodati sitno seckan paradajz", "Sipati u tiganj i prziti"
        ], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, ingredients: [], steps: [
            "Uzeti jedno parce hleba", "Staviti pecenicu na njega", "Staviti kackavalj preko", "Staviti drugo parce hleba"
        ], category: .snack)
    ]
    
    private var recipes: [Recipe] = []
    var isLoaded = false
    
    func loadFile() {
        do {
            let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Datafeed.shared.kAppGroup) //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
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
            return Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        }
        
        let rec = Recipe(name: "", prepTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        for recipeKey in r.keys {
            switch recipeKey {
            case "name":
                rec.name = (r["name"] as? String ?? "")
            case "prepTime":
                rec.prepTime = (r["prepTime"] as? Int ?? 0)
            case "ingredients":
                let stringIngredients = (r["ingredients"] as? [String] ?? [])
                var ingredients: [Ingredient] = []
                for stringIngredient in stringIngredients {
                    let parts = stringIngredient.split(separator: "_")
                    if parts.count != 3 {
                        continue
                    }
                    let quantity = parts[0]
                    let measureUnit = parts[1]
                    let ingredient = parts[2]
                    ingredients.append(Ingredient(quantity: Int(quantity) ?? 0, measureUnit: String(measureUnit), ingredient: String(ingredient)))
                }
                rec.ingredients = ingredients
            case "steps":
                rec.steps = (r["steps"] as? [String] ?? [])
            case "isFavorite":
                rec.isFavorite = (r["isFavorite"] as? Bool ?? false)
            case "isMyRecipe":
                rec.isMyRecipe = (r["isMyRecipe"] as? Bool ?? false)
            case "category":
                rec.category = RecipeCategory(rawValue: (r["category"] as? Int ?? 0))
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
    
    var myRecipes: [Recipe] {
        get {
            let filtered = self.recipes.filter {
                $0.isMyRecipe ?? false
            }
            return filtered
        }
    }
    
    let kAppGroup = "group.com.kulinarstvo_slasno_i_efikasno"
}

extension Datafeed : RecipeModelDelegate {
    func recipeModelDidChange(recipes: [Recipe]) {
        self.recipes = recipes
    }
    
}
