//
//  RecipeImageTableViewCell.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.12.22..
//

import UIKit

class RecipeImageTableViewCell : UITableViewCell {

    @IBOutlet weak var recipeLeftImageView: UIImageView!
    @IBOutlet weak var recipeLeftLabel: UILabel!
    @IBOutlet weak var recipeRightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
