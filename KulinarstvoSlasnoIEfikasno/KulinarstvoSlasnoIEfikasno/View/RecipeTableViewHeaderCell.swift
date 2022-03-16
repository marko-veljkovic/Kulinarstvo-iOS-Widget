//
//  RecipeTableViewHeaderCell.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 27.1.22.
//

import UIKit

protocol RecipeTableViewHeaderCellDelegate : AnyObject {
    func prepTimeSortClicked(headerCell: RecipeTableViewHeaderCell)
}

class RecipeTableViewHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var sortArrowImage: UIImageView!
    
    weak var delegate: RecipeTableViewHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.prepTimeLabel.text = "Vreme pripreme \n u minutima"
        
        [self.prepTimeLabel, self.sortArrowImage].forEach {
            $0?.isUserInteractionEnabled = true
            $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sortByPrepTimeClicked)))
        }
    }
    
    @objc func sortByPrepTimeClicked() {
        self.delegate?.prepTimeSortClicked(headerCell: self)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
