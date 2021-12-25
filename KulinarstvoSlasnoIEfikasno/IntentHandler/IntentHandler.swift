//
//  IntentHandler.swift
//  IntentHandler
//
//  Created by Marko Veljkovic private on 25.12.21.
//

import Intents
//import

class IntentHandler: INExtension {
    
//    func provideRecepieList(for intent: ConfigurationIntent) {
//
//    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler : ConfigurationIntentHandling {
    func resolveParameterToShow(for intent: ConfigurationIntent, with completion: @escaping (Enum1ResolutionResult) -> Void) {
        
    }
    
    
    func provideRecipeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<ReceptTip>?, Error?) -> Void) {
        let recipes = RecipeModel.testData.map { recipe in
            ReceptTip(identifier: recipe.name, display: recipe.name)
//            Recipe(name: recipe.name, prepTime: recipe.prepTime, ingredients: recipe.ingredients, steps: recipe.steps, isFavorite: recipe.isFavorite)
        }
        let collection = INObjectCollection(items: recipes)
        completion(collection, nil)
    }
    
    func defaultRecipe(for intent: ConfigurationIntent) -> ReceptTip? {
        let recipe = RecipeModel.testData[0]
        return ReceptTip(identifier: recipe.name, display: recipe.name)
    }
    
}
