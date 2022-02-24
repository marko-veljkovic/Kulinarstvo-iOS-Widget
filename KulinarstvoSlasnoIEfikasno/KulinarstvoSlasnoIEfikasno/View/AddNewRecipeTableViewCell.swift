//
//  AddNewRecipeTableViewCell.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

protocol AddNewRecipeTableViewCellDelegate : AnyObject {
    func addNewTextField(_ tableViewCell: UITableViewCell, _ tableView: UITableView?)
    func textFieldDidEndEditingInCell(_ tableViewCell: UITableViewCell, _ tableView: UITableView?, _ text: String?, _ textField: UITextField, isMeasure: Bool, isIngredient: Bool)
}

class AddNewRecipeTableViewCell: UITableViewCell {

    weak var delegate: AddNewRecipeTableViewCellDelegate?
    
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var addNewTextFieldButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [self.cellTextField, self.quantityTextField, self.ingredientTextField].forEach {
            $0?.delegate = self
            $0?.autocorrectionType = .no
        }
        self.cellTextField.delegate = self
        self.quantityTextField.delegate = self
        self.ingredientTextField.delegate = self
        self.addNewTextFieldButton.tintColor = AppTheme.backgroundUniversalGreen
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addNewTextFieldButtonClicked(_ sender: Any) {
        self.delegate?.addNewTextField(self, self.superview as? UITableView)
    }
}

extension AddNewRecipeTableViewCell : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.delegate?.textFieldDidEndEditingInCell(self, self.superview as? UITableView, textField.text, textField, isMeasure: textField === self.cellTextField, isIngredient: textField === self.ingredientTextField)
    }
}
