//
//  AddNewRecipeTableViewCell.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

protocol AddNewRecipeTableViewCellDelegate : AnyObject {
    func removeTextField(_ tableViewCell: UITableViewCell, cellIndex: Int)
    func textFieldDidEndEditingInCell(_ tableViewCell: UITableViewCell, _ tableView: UITableView?, _ text: String?, _ textField: UITextField, isMeasure: Bool, isIngredient: Bool)
}

class AddNewRecipeTableViewCell: UITableViewCell {

    weak var delegate: AddNewRecipeTableViewCellDelegate?
    
    @IBOutlet weak var cellStackView: UIStackView!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var removeTextFieldButton: UIButton!
    
    var cellIndex = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [self.cellTextField, self.quantityTextField, self.ingredientTextField].forEach {
            $0?.delegate = self
            $0?.autocorrectionType = .no
        }
//        self.cellTextField.delegate = self
//        self.quantityTextField.delegate = self
//        self.ingredientTextField.delegate = self
        self.removeTextFieldButton.tintColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func removeTextFieldButtonClicked(_ sender: Any) {
        self.delegate?.removeTextField(self, cellIndex: self.cellIndex)
    }
}

extension AddNewRecipeTableViewCell : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.delegate?.textFieldDidEndEditingInCell(self, self.superview as? UITableView, textField.text, textField, isMeasure: textField === self.cellTextField, isIngredient: textField === self.ingredientTextField)
    }
}
