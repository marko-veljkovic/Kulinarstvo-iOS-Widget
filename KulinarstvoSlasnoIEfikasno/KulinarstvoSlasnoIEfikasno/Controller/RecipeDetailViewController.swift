//
//  RecipeDetailViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21..
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var recipe: Recipe?
    
    init(recipe: Recipe?) {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        
        self.titleLabel?.text = recipe?.name
        
        var recipeImage = UIImage(named: recipe?.imageName ?? "")
        
        if recipeImage == nil, let imageData = UserDefaults.standard.object(forKey: recipe?.imageName ?? "") as? Data {
            recipeImage = UIImage(data: imageData)
        }

        self.recipeImageView.image = recipeImage //UIImage(named: recipe?.imageName ?? "")
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
        return (section == 0 ? self.recipe?.ingredients.count : self.recipe?.steps.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let wantedList = indexPath.section == 0 ? self.recipe?.ingredients : self.recipe?.steps
        
        cell.textLabel?.text = wantedList?[indexPath.row]
        return cell
    }
    
    
}
