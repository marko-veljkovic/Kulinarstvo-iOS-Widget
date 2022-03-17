//
//  IntentHandler.swift
//  IntentHandler
//
//  Created by Marko Veljkovic private on 25.12.21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if !Datafeed.shared.recipeModel.isLoaded {
            Datafeed.shared.recipeModel.loadFile()
        }
       
        return self
    }
}

extension IntentHandler : ConfigurationIntentHandling {
    func resolveParameterToShow(for intent: ConfigurationIntent, with completion: @escaping (Enum1ResolutionResult) -> Void) {
        
    }
    
    func provideRecipeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<ReceptTip>?, Error?) -> Void) {
        // Get dynamic list of users favorites recipes and show it in list for configuration
        let recipes = Datafeed.shared.favRecipes.map { recipe in
            ReceptTip(identifier: recipe.name, display: recipe.name)
        }
        let collection = INObjectCollection(items: recipes)
        completion(collection, nil)
    }
    
    func defaultRecipe(for intent: ConfigurationIntent) -> ReceptTip? {
        let recipe = Datafeed.shared.favRecipes.count > 0 ? Datafeed.shared.favRecipes[0] : RecipeModel.testData[0]
        return ReceptTip(identifier: recipe.name, display: recipe.name)
    }
    
}
