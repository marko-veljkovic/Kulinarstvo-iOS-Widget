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
    @IBOutlet weak var numOfPersonsTextField: UITextField!
    @IBOutlet weak var isFavoritesLabel: UILabel!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var stepsTableView: UITableView!
    
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var isFavoritesSwitch: UISwitch!
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    var imagePicker = UIImagePickerController()
    
    weak var delegate: NewRecipeViewControllerDelegate?
    
    var ingrediantsNumber = 3
    var stepsNumber = 3
    
    var ingrediantsMap: [String : Ingredient] = ["0":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "1":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "2":Ingredient(quantity: 0, measureUnit: "", ingredient: "")]
    var stepsMap: [String : String] = ["0":"", "1":"", "2":""]
    
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
        
        self.addNewRecipeLabel.text = "Dodaj novi recept"
        self.isFavoritesLabel.text = "Dodati u omiljene?"
        self.chooseImageButton.setTitle("Izaberi sliku jela", for: .normal)
        
        self.ingredientsTableView.dataSource = self
        self.stepsTableView.dataSource = self
        self.ingredientsTableView.delegate = self
        self.stepsTableView.delegate = self
        
        self.ingredientsTableView.register(UINib(nibName: "AddNewRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        self.stepsTableView.register(UINib(nibName: "AddNewRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        
        [self.addNewRecipeButton, self.chooseImageButton].forEach {
            $0?.backgroundColor = AppTheme.backgroundUniversalGreen
            $0?.setTitleColor(AppTheme.textUniversalGreen, for: .normal)
            
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        self.addNewRecipeButton.setTitle(self.existingRecipe != nil ? "Sacuvaj" : "Dodaj recept", for: .normal)
        
        if self.existingRecipe != nil {
            self.fillFields()
        }
    }
    
    func fillFields() {
        self.recipeNameTextField.text = self.existingRecipe!.name
        self.preparationTimeTextField.text = String(self.existingRecipe!.prepTime)
        self.numOfPersonsTextField.text = String(self.existingRecipe!.numOfPersons)
        self.isCurrentFavorites = self.existingRecipe!.isFavorite ?? false
        self.isFavoritesSwitch.isOn = self.existingRecipe!.isFavorite ?? false
        self.recipeImageView.image = UIImage(named: self.existingRecipe!.imageName)
        
        let selectedCategoryIndex = self.existingRecipe!.category?.rawValue ?? 0
        self.categoryPickerView.selectRow(selectedCategoryIndex, inComponent: 0, animated: true)
        
        self.ingrediantsNumber = self.existingRecipe!.ingredients.count != 0 ? self.existingRecipe!.ingredients.count : 1
        self.stepsNumber = self.existingRecipe!.steps.count != 0 ? self.existingRecipe!.steps.count : 1
        
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
        self.recipeNameTextField.becomeFirstResponder() // Added this line so that eventualy current selected text field in table view will lose focus and its value will be saved in map and sent further
        let recipeName = self.recipeNameTextField.text ?? ""
        let recipePrepTime = self.preparationTimeTextField.text ?? ""
        let recipeNumOfPersons = self.numOfPersonsTextField.text ?? ""
        
        self.saveImage(recipeName: recipeName)
        
        let sortedIngrediants = self.ingrediantsMap.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        let sortedSteps = self.stepsMap.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        
        var ingrediantsArray: [Ingredient] = []
        var stepsArray: [String] = []
        
        for ingrediant in sortedIngrediants where ingrediant.value.quantity != 0 {
            ingrediantsArray.append(Ingredient(quantity: ingrediant.value.quantity, measureUnit: ingrediant.value.measureUnit, ingredient: ingrediant.value.ingredient))
        }
        
        for step in sortedSteps where step.value != "" {
            stepsArray.append(step.value)
        }
        
        let newRecipe = Recipe(name: recipeName, prepTime: Int(recipePrepTime) ?? 0, ingredients: ingrediantsArray, steps: stepsArray, isFavorite: self.isCurrentFavorites, isMyRecipe: true, category: self.recipeCategory, numOfPersons: Int(recipeNumOfPersons) ?? 0)
        
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
    }
    
    @IBAction func chooseImageButtonClicked(_ sender: Any) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .savedPhotosAlbum
        self.imagePicker.allowsEditing = false
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
}

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
        UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.set(data(), forKey: recipeName)
    }
}

extension AddNewRecipeViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView === self.ingredientsTableView ? "Sastojci:" : "Koraci pripreme:"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.ingredientsTableView ? self.ingrediantsNumber : self.stepsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! AddNewRecipeTableViewCell
        cell.addNewTextFieldButton.isHidden = ((tableView === self.ingredientsTableView) ? !(indexPath.row == self.ingrediantsNumber - 1) : !(indexPath.row == self.stepsNumber - 1))
        cell.delegate = self
        
        if tableView === self.ingredientsTableView {
            
            cell.quantityTextField.placeholder = "Kolicina"
            cell.cellTextField.placeholder = "Jedinica mere"
            cell.ingredientTextField.placeholder = "Sastojak"
            
            let record = self.ingrediantsMap[String(indexPath.row)]
            if record != nil {
                cell.cellTextField.text = record!.measureUnit
                cell.ingredientTextField.text = record!.ingredient
                if record?.quantity != 0 {
                    cell.quantityTextField.text = String(record!.quantity)
                }
            }
        }
        else if tableView === self.stepsTableView {
            cell.quantityTextField.isHidden = true
            cell.ingredientTextField.isHidden = true
            let record = self.stepsMap[String(indexPath.row)]
            if record != nil {
                cell.cellTextField.text = record
            }
            else {
                cell.cellTextField.placeholder = "Korak"
            }
        }
        
        return cell
    }
}

extension AddNewRecipeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AddNewRecipeViewController : AddNewRecipeTableViewCellDelegate {
    func addNewTextField(_ tableViewCell: UITableViewCell, _ tableView: UITableView?) {
        if tableView === self.ingredientsTableView {
            self.ingrediantsNumber += 1
            self.ingredientsTableView.reloadData()
        }
        else if tableView === self.stepsTableView {
            self.stepsNumber += 1
            self.stepsTableView.reloadData()
        }
    }
    
    func textFieldDidEndEditingInCell(_ tableViewCell: UITableViewCell, _ tableView: UITableView?, _ text: String?, _ textField: UITextField, isMeasure: Bool, isIngredient: Bool) {
        
        guard let localText = text, localText != "" else {
            return
        }
        
        //Hacky way of getting indexPath, get textfield superview (cell content) and then it super view (cell)
        guard let index = tableView?.indexPathForRow(at: textField.superview?.superview?.superview?.frame.origin ?? CGPoint(x: 0, y: 0)) else {
            return
        }
        let rowIndex = index.row
        
        if tableView === self.ingredientsTableView {
            if isMeasure {
                self.ingrediantsMap[String(rowIndex)]?.measureUnit = localText
            }
            else if isIngredient {
                self.ingrediantsMap[String(rowIndex)]?.ingredient = localText
            }
            else {
                self.ingrediantsMap[String(rowIndex)]?.quantity = Double(localText) ?? 0
            }
        }
        else if tableView === self.stepsTableView {
            self.stepsMap[String(rowIndex)] = localText
        }
        
    }
}

extension AddNewRecipeViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = RecipeCategory(rawValue: row) ?? .snack
        switch category {
        case .coldSideDish:
            return "Hladno predjelo"
        case .warmSideDish:
            return "Toplo predjelo"
        case .mainDish:
            return "Glavno jelo"
        case .snack:
            return "Uzina"
        case .drink:
            return "Pice"
        case .soup:
            return "Supe i corbe"
        case .dessert:
            return "Dezert"
        case .salad:
            return "Salata"
        case .bread:
            return "Hleba"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.recipeCategory = RecipeCategory(rawValue: row) ?? .snack
    }
}

extension AddNewRecipeViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeCategory.allCases.count
    }
}
