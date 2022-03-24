//
//  AddNewRecipeViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

protocol NewRecipeViewControllerDelegate : AnyObject {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe)
    func controllerIsDismissed(_ controller: AddNewRecipeViewController)
    func didEditRecipe(_ controller: AddNewRecipeViewController, oldRecipe: Recipe, newRecipe: Recipe)
}

class AddNewRecipeViewController : UIViewController {

    @IBOutlet weak var addNewRecipeLabel: UILabel!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var preparationTimeTextField: UITextField!
    @IBOutlet weak var cookingTimeTextField: UITextField!
    @IBOutlet weak var numOfPersonsTextField: UITextField!
    @IBOutlet weak var isFavoritesLabel: UILabel!
    
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var isFavoritesSwitch: UISwitch!
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    @IBOutlet weak var addIngrediantsButton: UIButton!
    @IBOutlet weak var addStepsButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    weak var delegate: NewRecipeViewControllerDelegate?
    
    var ingrediantsMap: [String : Ingredient]? // ["0":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "1":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "2":Ingredient(quantity: 0, measureUnit: "", ingredient: "")]
    var stepsMap: [String : String]? // ["0":"", "1":"", "2":""]
    
    var isCurrentFavorites = true
    
    var recipeCategory = RecipeCategory.snack
    
    var existingRecipe: Recipe?
    
    init(existingRecipe: Recipe? = nil) {
        self.existingRecipe = existingRecipe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This controller is used for both editing existing recipe and creating new recipe
        self.addNewRecipeLabel.text = self.existingRecipe != nil ? "Izmeni recept" : "Dodaj novi recept"
        self.isFavoritesLabel.text = "Dodati u omiljene?"
        self.chooseImageButton.setTitle("Izaberi sliku jela", for: .normal)
        
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        
        [self.addNewRecipeButton, self.chooseImageButton, self.addIngrediantsButton, self.addStepsButton].forEach {
            $0?.setTitleColor(.gray, for: .disabled)
            
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        self.addNewRecipeButton.setTitle(self.existingRecipe != nil ? "Sačuvaj" : "Dodaj recept", for: .normal)
        self.addNewRecipeButton.isEnabled = false
        
        [self.recipeNameTextField, self.preparationTimeTextField, self.cookingTimeTextField, self.numOfPersonsTextField].forEach {
            $0?.delegate = self
            $0?.autocorrectionType = .no
        }
        
        // If self.existingRecipe != nil is true, that means that user selected to edit one of his/hers recipes and all fields should be filled with that recipe data
        if self.existingRecipe != nil {
            self.fillFields()
        }
        
        self.setColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addIngrediantsButton.setTitle(self.ingrediantsMap != nil ? "Izmeni sastojke" : "Dodaj sastojke", for: .normal)
        self.addStepsButton.setTitle(self.stepsMap != nil ? "Izmeni korake" : "Dodaj korake", for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColors()
    }
    
    private func setColors() {
        [self.recipeNameTextField, self.preparationTimeTextField, self.cookingTimeTextField, self.numOfPersonsTextField].forEach {
            $0?.textColor = AppTheme.setTextColor()
        }
        
        [self.addNewRecipeLabel, self.isFavoritesLabel, self.categoryLabel].forEach {
            $0?.textColor = AppTheme.setTextColor()
        }
        
        [self.addNewRecipeButton, self.chooseImageButton, self.addIngrediantsButton, self.addStepsButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
        
        self.isFavoritesSwitch.onTintColor = AppTheme.setTextColor()
        self.navigationController?.navigationBar.tintColor = AppTheme.setTextColor()
    }
    
    private func fillFields() {
        self.recipeNameTextField.text = self.existingRecipe!.name
        self.preparationTimeTextField.text = String(self.existingRecipe!.prepTime)
        self.cookingTimeTextField.text = String(self.existingRecipe!.cookTime)
        self.numOfPersonsTextField.text = String(self.existingRecipe!.numOfPersons)
        self.isCurrentFavorites = self.existingRecipe!.isFavorite ?? false
        self.isFavoritesSwitch.isOn = self.existingRecipe!.isFavorite ?? false
        self.recipeImageView.image = UIImage(named: self.existingRecipe!.imageName)
        
        let selectedCategoryIndex = self.existingRecipe!.category?.rawValue ?? 0
        self.categoryPickerView.selectRow(selectedCategoryIndex, inComponent: 0, animated: true)
        
        var localIngredientMap: [String:Ingredient] = [:]
        for (ingredientIndex, ingredient) in self.existingRecipe!.ingredients.enumerated() {
            localIngredientMap[String(ingredientIndex)] = ingredient
        }
        if self.existingRecipe!.ingredients.count != 0 {
            self.ingrediantsMap = localIngredientMap
        }
        else {
            self.ingrediantsMap = ["0":Ingredient(quantity: 0, measureUnit: "", ingredient: "")]
        }
        
        var localStepsMap: [String:String] = [:]
        for (stepIndex, step) in self.existingRecipe!.steps.enumerated() {
            localStepsMap[String(stepIndex)] = step
        }
        if self.existingRecipe!.steps.count != 0 {
            self.stepsMap = localStepsMap
        }
        else {
            self.stepsMap = ["0":""]
        }
    }

    @IBAction func addNewRecipeButtonClicked(_ sender: Any) {
        let recipeName = self.recipeNameTextField.text ?? ""
        let recipePrepTime = self.preparationTimeTextField.text ?? ""
        let recipeCookTime = self.cookingTimeTextField.text ?? ""
        let recipeNumOfPersons = self.numOfPersonsTextField.text ?? ""
        
        self.saveImage(recipeName: recipeName)
        
        // Dictionaries doesn't save data order, but we have to keep track of steps order for recipe
        // For ingredients it's not necessary but it's nice
        let sortedIngrediants = self.ingrediantsMap?.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        let sortedSteps = self.stepsMap?.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        
        var ingrediantsArray: [Ingredient] = []
        var stepsArray: [String] = []
        
        for ingrediant in sortedIngrediants ?? [] where ingrediant.value.quantity != 0 {
            ingrediantsArray.append(Ingredient(quantity: ingrediant.value.quantity, measureUnit: ingrediant.value.measureUnit, ingredient: ingrediant.value.ingredient))
        }
        
        for step in sortedSteps ?? [] where step.value != "" {
            stepsArray.append(step.value)
        }
        
        let newRecipe = Recipe(name: recipeName, prepTime: Int(recipePrepTime) ?? 0, cookTime: Int(recipeCookTime) ?? 0, ingredients: ingrediantsArray, steps: stepsArray, isFavorite: self.isCurrentFavorites, isMyRecipe: true, category: self.recipeCategory, numOfPersons: Int(recipeNumOfPersons) ?? 0)
        
        if self.existingRecipe != nil {
            self.delegate?.didEditRecipe(self, oldRecipe: self.existingRecipe!, newRecipe: newRecipe)
        }
        else {
            self.delegate?.didAddNewRecipe(self, newRecipe: newRecipe)
        }
        
        self.navigationController?.popViewController(animated: true)
        self.delegate?.controllerIsDismissed(self)
    }
    
    @IBAction func isFavoritesSwitchSwitched(_ sender: Any) {
        self.isCurrentFavorites = !isCurrentFavorites
        self.addNewRecipeButton.isEnabled = true
    }
    
    @IBAction func chooseImageButtonClicked(_ sender: Any) {
        self.addNewRecipeButton.isEnabled = true
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .savedPhotosAlbum
        self.imagePicker.allowsEditing = false
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addIngredientsButtonClicked(_ sender: Any) {
        self.addNewRecipeButton.isEnabled = true
        self.openItemsTableView(itemType: .ingredients)
    }
    
    @IBAction func addStepsButtonClicked(_ sender: Any) {
        self.addNewRecipeButton.isEnabled = true
        self.openItemsTableView(itemType: .steps)
    }
    
    func openItemsTableView(itemType: TableViewType) {
        let ingrediantsStepsViewController = IngrediantsStepsViewController(type: itemType)
        ingrediantsStepsViewController.delegate = self
        
        if ingrediantsMap != nil {
            ingrediantsStepsViewController.ingrediantsMap = self.ingrediantsMap!
        }
        if stepsMap != nil {
            ingrediantsStepsViewController.stepsMap = self.stepsMap!
        }
        
        self.navigationController?.pushViewController(ingrediantsStepsViewController, animated: true)
    }
}

//MARK: - IngrediantsStepsViewControllerDelegate
extension AddNewRecipeViewController : IngrediantsStepsViewControllerDelegate {
    func itemsDidSave(_ controller: IngrediantsStepsViewController, _ ingredients: [String : Ingredient]?, _ steps: [String : String]?) {
        if ingredients != nil {
            self.ingrediantsMap = ingredients!
        }
        else if steps != nil {
            self.stepsMap = steps!
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AddNewRecipeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.recipeImageView.image = info[.originalImage] as? UIImage
        self.recipeImageView.backgroundColor = .clear
        self.dismiss(animated: true, completion: nil)
    }
    
    private func saveImage(recipeName: String) {
        guard let image = self.recipeImageView.image else {
            return
        }
        
        let data = UIImage.pngData(image)
        // Saving recipe image in user defaults with recipe name as it's key
        UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.set(data(), forKey: recipeName)
    }
}

//MARK: - UIPickerViewDelegate
extension AddNewRecipeViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let category = RecipeCategory(rawValue: row) ?? .snack
        let stringToReturn = Datafeed.shared.recipeCategoryName(currentCategory: category)
        
        return NSAttributedString(string: stringToReturn, attributes: [.foregroundColor : AppTheme.setTextColor()])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.addNewRecipeButton.isEnabled = true
        self.recipeCategory = RecipeCategory(rawValue: row) ?? .snack
    }
}

//MARK: - UIPickerViewDataSource
extension AddNewRecipeViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeCategory.allCases.count
    }
}

//MARK: - UITextFieldDelegate
extension AddNewRecipeViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.existingRecipe != nil || textField === self.recipeNameTextField {
            self.addNewRecipeButton.isEnabled = true
        }
    }
}
