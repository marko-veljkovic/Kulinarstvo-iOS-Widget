//
//  RecipeModel.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

public struct Ingredient : Codable {
    var ingredient: String
    var measureUnit: String
    var quantity: Double
    
    init(ingredient: String, measureUnit: String, quantity: Double) {
        self.ingredient = ingredient
        self.measureUnit = measureUnit
        self.quantity = quantity
    }
}

public struct Recipe : Codable {
    @DocumentID var id: String?
    var name: String
    var prepTime: Int // In minutes
    var cookTime: Int // In minutes
    
    var ingredients: [Ingredient]
    var steps: [String]
    
    var isFavorite: Bool?
    var isMyRecipe: Bool?
    
    var category: RecipeCategory?
    
    var numOfPersons: Int = 0
    
    // Variable 'stringIngredients' is used for formatting ingredient print
    var stringIngredients: [String] {
        var stringIngredients: [String] = []
        for ingredient in self.ingredients {
            let tmp = ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", ingredient.quantity) : String(ingredient.quantity)
            let stringIngredient = tmp + " \(ingredient.measureUnit) \(ingredient.ingredient)"
            stringIngredients.append(stringIngredient)
        }
        return stringIngredients
    }
    
    var url: URL? {
        return URL(string: "kulinarstvoslasnoiefikasno://" + name.replacingOccurrences(of: " ", with: ""))
    }
    
    var imageName: String {
        return name
    }
    
    init(name: String, prepTime: Int, cookTime: Int, ingredients: [Ingredient], steps: [String], isFavorite: Bool? = false, isMyRecipe: Bool? = false, category: RecipeCategory, numOfPersons: Int = 0) {
        self.name = name
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.isMyRecipe = isMyRecipe
        self.category = category
        self.numOfPersons = numOfPersons
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
        Recipe(name: "Omlet", prepTime: 15, cookTime: 15, ingredients: [
            Ingredient(ingredient: "jaja", measureUnit: "komada", quantity: 3),
            Ingredient(ingredient: "sira", measureUnit: "grama", quantity: 20),
            Ingredient(ingredient: "persun", measureUnit: "kasicica", quantity: 1)
        ], steps: [
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu",
            "Izmutiti jaja sitno i brzo", "Dodati sitno", "Lorem ipsum za proveru duzine i sirine opisa postupka", "Sipati u tiganj i prziti", "Proba", "priprema", "7 korak po redu"
        ], category: .warmSideDish),
        Recipe(name: "Spagete karbonara", prepTime: 45, cookTime: 15, ingredients: [], steps: [], category: .mainDish),
        Recipe(name: "Pirinac", prepTime: 20, cookTime: 15,
               ingredients: [Ingredient(ingredient: "pirinac", measureUnit: "grama", quantity: 200),
                             Ingredient(ingredient: "zejtin", measureUnit: "kasike", quantity: 2),
                             Ingredient(ingredient: "soli", measureUnit: "prstohvat", quantity: 1),
                             Ingredient(ingredient: "voda", measureUnit: "mililitra", quantity: 400)],
               steps: [ "Oprati pirinac", "Dodati vodu", "Dodati zejtin", "Dodati so", "Kuvati 20ak minuta"], category: .warmSideDish),
        Recipe(name: "Mesano povrce", prepTime: 25, cookTime: 15, ingredients: [], steps: [], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, cookTime: 15, ingredients: [], steps: [], category: .bread),
        Recipe(name: "Cezar salata", prepTime: 75, cookTime: 15,
               ingredients: [Ingredient(ingredient: "slanina", measureUnit: "grama", quantity: 400)], //Ingredient(ingredient: 1, measureUnit: "kilogram", quantity: "pilece belo"), Ingredient(ingredient: 2, measureUnit: "glavice", quantity: "zelena salata"), Ingredient(ingredient: 400, measureUnit: "grama", quantity: "cheri paradajz"), Ingredient(ingredient: 6, measureUnit: "kriski", quantity: "hleba"), Ingredient(ingredient: 600, measureUnit: "grama", quantity: "cezar preliv")],
               steps: ["Iseckati slaninu na kockice", "Proprziti slaninu", "Iseckati pilece belo na kockice", "Proprziti pilece belo", "Iseckati hleba na kockice", "Umedjuvremenu nacepkati listove zelene salate u ciniju", "Naseci cheri paradajz i dodati u ciniju", "Kada hleb zapece skloniti sa ringle i sve dodati u ciniju", "Dodati cezar preliv", "Promesati sve i uzivati"],
               isFavorite: true, isMyRecipe: true, category: .salad, numOfPersons: 6)
    ]

    static var myTestData = [
        Recipe(name: "Omlet", prepTime: 15, cookTime: 15, ingredients: [
            Ingredient(ingredient: "jaja", measureUnit: "komada", quantity: 3),
            Ingredient(ingredient: "sira", measureUnit: "grama", quantity: 20)
        ], steps: [
            "Izmutiti jaja", "Dodati sitno seckan paradajz", "Sipati u tiganj i prziti"
        ], category: .warmSideDish),
        Recipe(name: "Sendvic", prepTime: 5, cookTime: 15, ingredients: [], steps: [
            "Uzeti jedno parce hleba", "Staviti pecenicu na njega", "Staviti kackavalj preko", "Staviti drugo parce hleba"
        ], category: .snack)
    ]
    
    fileprivate var recipes: [Recipe] = []
    var isLoaded = false
}

// Loading file with recipes
extension RecipeModel {
    func loadFile() {
        do {
            let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Datafeed.shared.kAppGroup)
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
            //If file exist only local
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
}

// Parsing recipe data
extension RecipeModel {
    func parseRecipe(recipe: Any) -> Recipe {
        guard let r = recipe as? [String:Any] else {
            return Recipe(name: "", prepTime: 0, cookTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        }
        
        var rec = Recipe(name: "", prepTime: 0, cookTime: 0, ingredients: [], steps: [], isFavorite: false, category: .snack)
        for recipeKey in r.keys {
            switch recipeKey {
            case "name":
                rec.name = (r["name"] as? String ?? "")
            case "prepTime":
                rec.prepTime = (r["prepTime"] as? Int ?? 0)
            case "cookTime":
                rec.cookTime = (r["cookTime"] as? Int ?? 0)
            case "ingredients":
                // Ingredients are stored with '_' between 3 properties -> 'quantity_measureUnit_ingredient'
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
                    ingredients.append(Ingredient(ingredient: String(ingredient), measureUnit: String(measureUnit), quantity: Double(quantity) ?? 0))
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
            case "numOfPersons":
                rec.numOfPersons = (r["numOfPersons"] as? Int ?? 0)
            default:
                ()
            }
        }
        return rec
    }
}
