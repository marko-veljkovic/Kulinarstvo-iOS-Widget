//
//  SceneDelegate.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var shouldSave = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        window?.rootViewController = TabBarViewController()
        
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.shouldSave = true
        
        guard let url = URLContexts.first?.url else {
            return
        }
        let urlStr = url.absoluteString
        
        guard let recipe = RecipeModel.testData.first(where: {$0.url?.absoluteString == urlStr}) else {
            return
        }
        
        let cv = window?.rootViewController as! TabBarViewController
        (cv.selectedViewController as? UINavigationController)?.pushViewController(RecipeDetailViewController(recipe: recipe), animated: true)
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        if self.shouldSave {
            self.saveRecipes()
            self.shouldSave = false
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        self.shouldSave = true
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        if self.shouldSave {
            self.saveRecipes()
            self.shouldSave = false
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        self.shouldSave = true
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        if self.shouldSave {
            self.saveRecipes()
            self.shouldSave = false
        }
    }
    
    private func saveRecipes() {
        let finalRecipes = Datafeed.shared.recipes
        var topLevel: [String : Any] = [:]
        var topLevelRecipes: [Any] = []
        for recipe in finalRecipes {
            var recipeDict: [String : Any] = [:]
            recipeDict["name"] = recipe.name
            recipeDict["prepTime"] = recipe.prepTime
            recipeDict["ingredients"] = recipe.ingredients
            recipeDict["steps"] = recipe.steps
            recipeDict["isFavorite"] = recipe.isFavorite
            topLevelRecipes.append(recipeDict)
        }
        topLevel = ["recipes" : topLevelRecipes]
        
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = dir?.appendingPathComponent("RecipesData.json")
            
            
//            let path = Bundle.main.path(forResource: "RecipesData", ofType: "json")
//            let jsonURL = URL(fileURLWithPath: path ?? "")
            let jsonData = try JSONSerialization.data(withJSONObject: topLevel, options: .prettyPrinted)
            try jsonData.write(to: fileURL!)
        }
        catch {
            
        }
    }


}

