//
//  RecipeDetailViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var preparationTimeLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var numOfPersonsTextLabel: UILabel!
    @IBOutlet weak var decreaseNumOfPersons: UIButton!
    @IBOutlet weak var increaseNumOfPersons: UIButton!
    @IBOutlet weak var isFavoritesSwitch: UISwitch!
    @IBOutlet weak var changeRecipeButton: UIButton!
    @IBOutlet weak var deleteRecipeButton: UIButton!
    
    var localNumberOfPersons: Int = 0
    var localPrepTime: Int = 0
    var localCookTime: Int = 0
    var localPrepTimeFactor: Double = 0.25
    var localArrayOfIngredients: [Ingredient] = []
    var oldRecipeIndex: Int?
    
    var localStringIngredients: [String] {
        var stringIngredients: [String] = []
        for ingredient in self.localArrayOfIngredients {
            let tmp = ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", ingredient.quantity) : String(format: "%.2f", ingredient.quantity)
            let stringIngredient = tmp + " \(ingredient.measureUnit) \(ingredient.ingredient)"
            stringIngredients.append(stringIngredient)
        }
        return stringIngredients
    }
    
    var recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.changeRecipeButton.setTitle("Izmeni recept", for: .normal)
        self.changeRecipeButton.isHidden = !(self.recipe.isMyRecipe ?? false)
        
        self.deleteRecipeButton.setTitle("Obriši recept", for: .normal)
        self.deleteRecipeButton.isHidden = !(self.recipe.isMyRecipe ?? false)
        self.deleteRecipeButton.backgroundColor = .red
        self.deleteRecipeButton.layer.cornerRadius = 10
        self.deleteRecipeButton.layer.borderWidth = 2
        self.deleteRecipeButton.layer.borderColor = UIColor.red.cgColor
        
        [self.increaseNumOfPersons, self.decreaseNumOfPersons, changeRecipeButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        self.decreaseNumOfPersons.setTitleColor(UIColor.gray, for: .disabled)
        self.decreaseNumOfPersons.setTitleShadowColor(.gray, for: .disabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.oldRecipeIndex != nil {
            self.recipe = Datafeed.shared.recipes[self.oldRecipeIndex!]
        }
        self.setColors()
        self.setRecipeData()
    }
    
    func setColors() {
        [self.increaseNumOfPersons, self.decreaseNumOfPersons, changeRecipeButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
        [self.titleLabel, self.numOfPersonsTextLabel, self.preparationTimeLabel, self.cookingTimeLabel].forEach {
            $0?.textColor = AppTheme.setTextColor()
        }
        self.navigationController?.navigationBar.tintColor = AppTheme.setTextColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColors()
        self.tableView.reloadData()
    }
    
    func setRecipeData() {
        self.localNumberOfPersons = self.recipe.numOfPersons
        self.localPrepTime = self.recipe.prepTime
        self.localCookTime = self.recipe.cookTime
        self.localArrayOfIngredients = self.recipe.ingredients
        
        self.titleLabel?.text = self.recipe.name
        
        let recipeCategory = self.recipe.category ?? .snack
        self.categoryLabel.text = Datafeed.shared.recipeCategoryName(currentCategory: recipeCategory)
        
        var recipeImage = UIImage(named: self.recipe.imageName)
        
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: self.recipe.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }

        self.recipeImageView.image = recipeImage
        self.setNumberOfPersonsField()
        self.setPrepAndCookTime()
        self.tableView.reloadData()
        
        self.isFavoritesSwitch.isOn = self.recipe.isFavorite ?? false
    }
    
    func setNumberOfPersonsField() {
        self.numOfPersonsTextLabel.text = "Sastojci potrebni za \(self.localNumberOfPersons) " + self.correctFormOFString()
        
        self.decreaseNumOfPersons.isEnabled = self.localNumberOfPersons > 1
        self.decreaseNumOfPersons.alpha = self.localNumberOfPersons > 1 ? 1 : 0.5
    }
    
    func correctFormOFString() -> String {
        switch self.localNumberOfPersons {
        case 1:
            return "osobu"
        case 2..<5:
            return "osobe"
        default:
            return "osoba"
        }
    }
    
    func setPrepAndCookTime() {
        self.preparationTimeLabel.text = "Vreme pripreme: \(self.localPrepTime) minuta"
        self.cookingTimeLabel.text = "Vreme spremanja: \(self.localCookTime) minuta"
    }
    
    @IBAction func decreaseNumOfPersonsButtonClicked(_ sender: Any) {
        self.localNumberOfPersons -= 1
        self.updateIngredientsQuantity()
        self.updatePrepAndCookTime(isDecrease: true)
        self.setNumberOfPersonsField()
    }
    
    @IBAction func increaseNumOfPersonsButtonClicked(_ sender: Any) {
        self.localNumberOfPersons += 1
        self.updateIngredientsQuantity()
        self.updatePrepAndCookTime()
        self.setNumberOfPersonsField()
    }
    
    @IBAction func changeRecipeButtonClicked(_ sender: Any) {
        let addNewRecipeViewController = AddNewRecipeViewController(existingRecipe: self.recipe)
        addNewRecipeViewController.delegate = self
        self.navigationController?.pushViewController(addNewRecipeViewController, animated: true)
    }
    
    @IBAction func deleteRecipeButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Obrisati recept?", message: "Da li ste sigurni da želite da obrišete recept", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Odustani", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Obriši", style: .destructive, handler: { _ in
            guard let currentRecipeIndex = Datafeed.shared.recipes.firstIndex(where: {
                $0.name == self.recipe.name
            }) else {
                return
            }
            Datafeed.shared.recipes.remove(at: currentRecipeIndex)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Changes when user increase or decrease number of persons he's prepearing meal for
    func updateIngredientsQuantity() {
        for (indexList, ingredient) in self.recipe.ingredients.enumerated() {
            let forDelt = Double(self.localNumberOfPersons) / Double(self.recipe.numOfPersons)
            self.localArrayOfIngredients[indexList].quantity = ingredient.quantity * forDelt
        }
        self.tableView.reloadData()
    }
    
    // Changes when user increase or decrease number of persons he's prepearing meal for
    func updatePrepAndCookTime(isDecrease: Bool = false) {
        if isDecrease {
            // Prep time is decreased for small value every time user decrease number of persons for recipe (each prep time descrease is larger then the last one)
            self.localPrepTime = self.localPrepTime - Int(Double(self.recipe.prepTime) * self.localPrepTimeFactor)
            if self.localPrepTimeFactor > 0.025 {
                self.localPrepTimeFactor -= 0.025
            }
            // Cook time is decreased for small value when number of persons drop to 14 or 6
            if localNumberOfPersons == 6 {
                self.localCookTime -= Int(Double(self.recipe.cookTime) * 0.25)
            }
            if localNumberOfPersons == 14 {
                self.localCookTime -= Int(Double(self.recipe.cookTime) * 0.5)
            }
        }
        else {
            // Prep time is increased for small value every time user increase number of persons for recipe (each prep time inscrease is smaller then the last one)
            self.localPrepTime = self.localPrepTime + Int(Double(self.recipe.prepTime) * self.localPrepTimeFactor)
            if self.localPrepTimeFactor > 0.025 {
                self.localPrepTimeFactor -= 0.025
            }
            // Cook time is increased for small value when number of persons goes to 15 or 7
            if localNumberOfPersons == 7 {
                self.localCookTime += Int(Double(self.recipe.cookTime) * 0.25)
            }
            if localNumberOfPersons == 15 {
                self.localCookTime += Int(Double(self.recipe.cookTime) * 0.5)
            }
        }
        self.setPrepAndCookTime()
    }
    
    @IBAction func isFavoritedRecipeSwitched(_ sender: Any) {
        // If user click on switch and add/remove recipe from favorites, recipe data will be refreshed
        let newRecipe = self.recipe
        newRecipe.isFavorite = !(newRecipe.isFavorite ?? true)
        guard let oldRecipeIndex = Datafeed.shared.recipes.firstIndex(where: {
            $0.name == self.recipe.name
        }) else {
            return
        }
        Datafeed.shared.recipes[oldRecipeIndex] = newRecipe
    }
}

extension RecipeDetailViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Sastojci" : "Priprema"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 ? self.recipe.ingredients.count : self.recipe.steps.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.numberOfLines = 0
        
        let wantedList = indexPath.section == 0 ? self.localStringIngredients : self.recipe.steps
        
        if indexPath.section != 0 || self.recipe.ingredients[indexPath.row].quantity != 0 {
            cell.textLabel?.text = wantedList[indexPath.row]
            cell.textLabel?.textColor = AppTheme.setTextColor()
        }
        return cell
    }
}

extension RecipeDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        header.textLabel?.textColor = AppTheme.setTextColor()
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .center
    }
}

//MARK: - NewRecipeViewControllerDelegate
extension RecipeDetailViewController : NewRecipeViewControllerDelegate {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe) {
        
    }
    
    func controllerIsDismissed(_ controller: AddNewRecipeViewController) {
        
    }
    
    func didEditRecipe(_ controller: AddNewRecipeViewController, oldRecipe: Recipe, newRecipe: Recipe) {
        // Recipe is being saved in recipe list after user edited it
        guard let oldRecipeIndex = Datafeed.shared.recipes.firstIndex(where: {
            $0.name == oldRecipe.name
        }) else {
            return
        }
        self.oldRecipeIndex = oldRecipeIndex
        Datafeed.shared.recipes[oldRecipeIndex] = newRecipe
    }
}
