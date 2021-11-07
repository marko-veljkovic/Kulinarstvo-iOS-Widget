//
//  AddNewRecipeTableViewCell.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

protocol AddNewRecipeTableViewCellDelegate : AnyObject {
    func addNewTextField(_ tableViewCell: UITableViewCell, _ tableView: UITableView?)
    func textFieldDidEndEditingInCell(_ tableViewCell: UITableViewCell, _ tableView: UITableView?, _ text: String?, _ textField: UITextField)
}

class AddNewRecipeTableViewCell: UITableViewCell {

    weak var delegate: AddNewRecipeTableViewCellDelegate?
    
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var addNewTextFieldButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellTextField.delegate = self
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
        self.delegate?.textFieldDidEndEditingInCell(self, self.superview as? UITableView, textField.text, textField)
    }
}
