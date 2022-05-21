//
//  IngrediantsStepsViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 19.2.22.
//

import UIKit

enum TableViewType {
    case ingredients, steps
}

protocol IngrediantsStepsViewControllerDelegate: AnyObject {
    func itemsDidSave(_ controller: IngrediantsStepsViewController, _ ingredients: [String : Ingredient]?, _ steps: [String : String]?)
}

class IngrediantsStepsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: IngrediantsStepsViewControllerDelegate?
    
    var type: TableViewType
    // When user create new recipe, 3 empty ingredients and 3 empty steps will be added in ingredients/steps list
    var ingrediantsNumber = 3
    var stepsNumber = 3
    var ingrediantsMap: [String : Ingredient] = ["0":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "1":Ingredient(quantity: 0, measureUnit: "", ingredient: ""), "2":Ingredient(quantity: 0, measureUnit: "", ingredient: "")]
    var stepsMap: [String : String] = ["0":"", "1":"", "2":""]
    
    var isSaveButtonClicked = false
    
    init(type: TableViewType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemsTableView.dataSource = self
        self.itemsTableView.dataSource = self
        self.itemsTableView.register(UINib(nibName: "AddNewRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        
        self.nameLabel.text = self.type == .ingredients ? "Sastojci" : "Koraci pripreme"
        
        self.addNewButton.setTitle(self.type == .ingredients ? "Dodaj novi sastojak" : "Dodaj novi korak", for: .normal)
        
        self.saveButton.setTitleColor(.gray, for: .disabled)
        
        [self.addNewButton, self.saveButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        self.ingrediantsNumber = self.ingrediantsMap.count
        self.stepsNumber = self.stepsMap.count
        
        self.setColors()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.itemsTableView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setColors() {
        [self.addNewButton, self.saveButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
        self.navigationController?.navigationBar.tintColor = AppTheme.setTextColor()
    }
    
    @IBAction func addNewButtonClicked(_ sender: Any) {
        if type == .ingredients {
            self.ingrediantsNumber += 1
            self.ingrediantsMap["\(self.ingrediantsNumber-1)"] = Ingredient(quantity: 0, measureUnit: "", ingredient: "")
        }
        else {
            self.stepsNumber += 1
            self.stepsMap["\(self.stepsNumber-1)"] = ""
        }
        self.itemsTableView.reloadData()
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.isSaveButtonClicked = true
        
        (self.itemsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddNewRecipeTableViewCell)?.cellTextField?.becomeFirstResponder()
        (self.itemsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddNewRecipeTableViewCell)?.cellTextField?.resignFirstResponder()
        // Added this line so that eventualy current selected text field in table view will lose focus and its value will be saved in map and sent further
    }
}

//MARK: - UITableViewDataSource
extension IngrediantsStepsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type == .ingredients ? self.ingrediantsNumber : self.stepsNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! AddNewRecipeTableViewCell
        cell.delegate = self
        cell.cellIndex = indexPath.row
        cell.selectionStyle = .none
        
        if self.type == .ingredients {
            cell.quantityTextField.placeholder = "Količina"
            cell.cellTextField.placeholder = "Jedinica mere"
            cell.ingredientTextField.placeholder = "Sastojak"
            
            [cell.quantityTextField, cell.cellTextField, cell.ingredientTextField].forEach {
//                $0?.delegate = self
                $0?.textColor = AppTheme.setTextColor()
            }
            
            let record = self.ingrediantsMap[String(indexPath.row)]
            if record != nil {
                cell.cellTextField.text = record!.measureUnit
                cell.ingredientTextField.text = record!.ingredient
                if record?.quantity != 0 {
                    cell.quantityTextField.text = String(record!.quantity)
                }
            }
        }
        else {
            cell.quantityTextField.isHidden = true
            cell.ingredientTextField.isHidden = true
            let record = self.stepsMap[String(indexPath.row)]
            if record != nil, !record!.isEmpty {
                cell.cellTextField.text = record
            }
            else {
                cell.cellTextField.placeholder = "Korak"
            }
//            cell.cellTextField.delegate = self
            cell.cellTextField.textColor = AppTheme.setTextColor()
            cell.cellStackView.spacing = 0
        }
        
        return cell
    }
}

//MARK: - AddNewRecipeTableViewCellDelegate
extension IngrediantsStepsViewController : AddNewRecipeTableViewCellDelegate {
    func removeTextField(_ tableViewCell: UITableViewCell, cellIndex: Int) {
        if self.type == .ingredients {
            self.ingrediantsNumber -= 1
            if self.ingrediantsMap.count > cellIndex {
                // Remove ingredient from map
                self.ingrediantsMap.removeValue(forKey: String(cellIndex))
                // For all other ingredients, have to lower key value by 1 so it could be manipuladted with after deletion
                for i in cellIndex..<ingrediantsMap.count {
                    if let entry = ingrediantsMap.removeValue(forKey: String(i+1)) {
                        ingrediantsMap[String(i)] = entry
                    }
                }
            }
        }
        else {
            self.stepsNumber -= 1
            if self.stepsMap.count > cellIndex {
                // Remove step from map
                self.stepsMap.removeValue(forKey: String(cellIndex))
                // For all other steps, have to lower key value by 1 so it could be manipuladted with after deletion
                for i in cellIndex..<stepsMap.count {
                    if let entry = stepsMap.removeValue(forKey: String(i+1)) {
                        stepsMap[String(i)] = entry
                    }
                }
            }
        }
        self.itemsTableView.reloadData()
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
        
        if self.type == .ingredients {
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
        else {
            self.stepsMap[String(rowIndex)] = localText
        }
        
        if self.isSaveButtonClicked {
            self.isSaveButtonClicked = false
            self.delegate?.itemsDidSave(self, self.type == .ingredients ? self.ingrediantsMap : nil, self.type == .steps ? self.stepsMap : nil)
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension IngrediantsStepsViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
