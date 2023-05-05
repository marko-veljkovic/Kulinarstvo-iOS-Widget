//
//  Datafeed.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 16.3.22.
//

import Foundation
import FirebaseAuth

protocol DatafeedDelegate : AnyObject {
    func recipesDataParsed()
}

public class Datafeed {
    
    static let shared = Datafeed()
    weak var delegate: DatafeedDelegate?
    
    let recipeRepository = RecipeRepository.shared
    let userRepository = UserRepository.shared
    
    lazy var recipeModel: RecipeModel = {
        var model = RecipeModel()
        model.delegate = self
        return model
    }()
    
    var recipes: [Recipe] = [] {
        didSet {
            self.delegate?.recipesDataParsed()
        }
    }
    
    var currentUser: LocalUser? = nil
    
    var favRecipes: [Recipe] {
        get {
            let filtered = self.recipes.filter {
                Datafeed.shared.currentUser?.favoriteRecipes?.contains($0.id ?? "") ?? false
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
    
    private init() {
        if let currentUser = Auth.auth().currentUser {
            self.userRepository.getCurrentUser(uuid: currentUser.uid)
        }
    }
    
    func recipeCategoryName(currentCategory: RecipeCategory?) -> String {
        switch currentCategory {
        case .coldSideDish:
            return "Hladno predjelo"
        case .warmSideDish:
            return "Toplo predjelo"
        case .mainDish:
            return "Glavno jelo"
        case .snack:
            return "Užina"
        case .drink:
            return "Piće"
        case .soup:
            return "Supe i čorbe"
        case .dessert:
            return "Dezert"
        case .salad:
            return "Salata"
        case .bread:
            return "Hleb"
        default:
            return "Izaberi kategoriju"
        }
    }
}

extension Datafeed : RecipeModelDelegate {
    func recipeModelDidChange(recipes: [Recipe]) {
        self.recipes = recipes
    }
}
