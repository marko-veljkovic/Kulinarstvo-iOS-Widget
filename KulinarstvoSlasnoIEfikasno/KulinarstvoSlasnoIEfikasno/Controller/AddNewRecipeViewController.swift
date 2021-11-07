//
//  AddNewRecipeViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21..
//

import UIKit

protocol NewRecipeViewControllerDelegate : AnyObject {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe)
    func controllerIsDismissed(_ controller: AddNewRecipeViewController)
}

class AddNewRecipeViewController : UIViewController {

    @IBOutlet weak var addNewRecipeLabel: UILabel!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var preparationTimeTextLabel: UITextField!
    @IBOutlet weak var isFavoritesLabel: UILabel!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var stepsTableView: UITableView!
    
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var isFavoritesSwitch: UISwitch!
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    weak var delegate: NewRecipeViewControllerDelegate?
    
    var ingrediantsNumber = 3
    var stepsNumber = 3
    
    var ingrediantsMap: [String : String] = ["0":"", "1":"", "2":""]
    var stepsMap: [String : String] = ["0":"", "1":"", "2":""]
    
    var isCurrentFavorites = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNewRecipeLabel.text = "Dodaj novi recept"
        self.isFavoritesLabel.text = "Dodati u omiljene?"
        self.chooseImageButton.titleLabel?.text = "Izaberi sliku jela"
        
        self.ingredientsTableView.dataSource = self
        self.stepsTableView.dataSource = self
        self.ingredientsTableView.delegate = self
        self.stepsTableView.delegate = self
        
        self.ingredientsTableView.register(UINib(nibName: "AddNewRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        self.stepsTableView.register(UINib(nibName: "AddNewRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        
        self.addNewRecipeButton.titleLabel?.text = "Dodaj"
    }

    @IBAction func addNewRecipeButtonClicked(_ sender: Any) {
        self.recipeNameTextField.becomeFirstResponder() // Added this line so that eventualy current selected text field in table view will lose focus and its value will be
                                                        // saved in map and sent further
        let recipeName = self.recipeNameTextField.text ?? ""
        let recipePrepTime = self.preparationTimeTextLabel.text ?? ""
        
        self.saveImage(recipeName: recipeName)
        
        let sortedIngrediants = self.ingrediantsMap.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        let sortedSteps = self.stepsMap.sorted(by: {Int($0.key) ?? 0 < Int($1.key) ?? 0})
        
        var ingrediantsArray: [String] = []
        var stepsArray: [String] = []
        
        for ingrediant in sortedIngrediants {
            ingrediantsArray.append(ingrediant.value)
        }
        
        for step in sortedSteps {
            stepsArray.append(step.value)
        }
        
        let newRecipe = Recipe(name: recipeName, prepTime: Int(recipePrepTime) ?? 0, ingredients: ingrediantsArray, steps: stepsArray, isFavorite: self.isCurrentFavorites)
        
        RecipeModel.myTestData.append(newRecipe)
        
        self.delegate?.didAddNewRecipe(self, newRecipe: newRecipe)
        
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
        
//        self.saveImage(image: info[.originalImage] as? UIImage)
    }
    
    private func saveImage(recipeName: String) {
        guard let image = self.recipeImageView.image else {
            return
        }
        
        let data = UIImage.pngData(image)
        UserDefaults.standard.set(data(), forKey: recipeName)
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
            let record = self.ingrediantsMap[String(indexPath.row)]
            if record != nil {
                cell.cellTextField.text = record
            }
            else {
                cell.cellTextField.text = ""
            }
        }
        else if tableView === self.stepsTableView {
            let record = self.stepsMap[String(indexPath.row)]
            if record != nil {
                cell.cellTextField.text = record
            }
            else {
                cell.cellTextField.text = ""
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
    
    func textFieldDidEndEditingInCell(_ tableViewCell: UITableViewCell, _ tableView: UITableView?, _ text: String?, _ textField: UITextField) {
        
        guard let localText = text, localText != "" else {
            return
        }
        
        //Hacky way of getting indexPath, get textfield superview (cell content) and then it super view (cell)
        guard let index = tableView?.indexPathForRow(at: textField.superview?.superview?.frame.origin ?? CGPoint(x: 0, y: 0)) else {
            return
        }
        let rowIndex = index.row
        
        if tableView === self.ingredientsTableView {
            self.ingrediantsMap[String(rowIndex)] = text
        }
        else if tableView === self.stepsTableView {
            self.stepsMap[String(rowIndex)] = text
        }
        
    }
}
