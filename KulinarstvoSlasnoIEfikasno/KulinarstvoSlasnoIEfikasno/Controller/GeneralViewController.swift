//
//  GeneralViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class GeneralViewController: UIViewController {
    
    var addNewRecipeViewController: AddNewRecipeViewController?
    
    var isFavorites: Bool
    var isMyRecipes: Bool
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewRecipeButton: UIButton!
    
    init(isFavorites: Bool = false, isMyRecipes: Bool = false) {
        self.isFavorites = isFavorites
        self.isMyRecipes = isMyRecipes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.recipeModel.loadFile()
        
        Datafeed.shared.delegate = self
        
        if !Datafeed.shared.recipeModel.isLoaded {
            Datafeed.shared.recipeModel.loadFile()
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        
        self.addNewRecipeButton.isHidden = !self.isMyRecipes
    }
    
    @IBAction func addNewRecipeButtonClicked(_ sender: Any) {
        self.addNewRecipeViewController = AddNewRecipeViewController()
        self.addNewRecipeViewController?.delegate = self
        
        self.navigationController?.pushViewController(self.addNewRecipeViewController!, animated: true)
    }
    
}

extension GeneralViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFavorites ? Datafeed.shared.favRecipes.count : self.isMyRecipes ? Datafeed.shared.myRecipes.count : Datafeed.shared.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
        
        let record = self.isFavorites ? Datafeed.shared.favRecipes[indexPath.row] :
                     self.isMyRecipes ? Datafeed.shared.myRecipes[indexPath.row] :
                                        Datafeed.shared.recipes[indexPath.row]
        
        cell.title?.text = record.name
        var recipeImage = UIImage(named: record.imageName)
        
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: record.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }
            
        cell.recipeImageView.image = recipeImage //UIImage(named: record.imageName)
        
        return cell
    }
}

extension GeneralViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let destination = RecipeDetailViewController(recipe: self.isFavorites ? Datafeed.shared.favRecipes[indexPath.row] : self.isMyRecipes ? Datafeed.shared.myRecipes[indexPath.row] : Datafeed.shared.recipes[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
    }
}

extension GeneralViewController : NewRecipeViewControllerDelegate {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe) {
        Datafeed.shared.recipes.append(newRecipe)
    }
    
    func controllerIsDismissed(_ controller: AddNewRecipeViewController) {
        self.addNewRecipeViewController = nil
    }
}

extension GeneralViewController : DatafeedDelegate {
    func recipesDataParsed() {
        self.tableView.reloadData()
    }
}
