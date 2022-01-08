//
//  RecipeDetailViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var numOfPersonsTextLabel: UILabel!
    @IBOutlet weak var decreaseNumOfPersons: UIButton!
    @IBOutlet weak var increaseNumOfPersons: UIButton!
    
    var localNumberOfPersons: Int = 0
    var localArrayOfIngredients: [Ingredient] = []
    
    var localStringIngredients: [String] {
        var stringIngredients: [String] = []
        for ingredient in self.localArrayOfIngredients {
            let tmp = ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", ingredient.quantity) : String(ingredient.quantity)
            let stringIngredient = tmp + " \(ingredient.measureUnit) \(ingredient.ingredient)"
            stringIngredients.append(stringIngredient)
        }
        return stringIngredients
    }
    
    var recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.localNumberOfPersons = self.recipe.numOfPersons
        self.localArrayOfIngredients = self.recipe.ingredients
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        
        self.titleLabel?.text = recipe.name
        
        let recipeCategory = recipe.category ?? .snack
        self.categoryLabel.text = {
            switch recipeCategory {
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
        }()
        
        var recipeImage = UIImage(named: recipe.imageName)
        
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: recipe.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }

        self.recipeImageView.image = recipeImage //UIImage(named: recipe?.imageName ?? "")
        
        self.setNumberOfPersonsField()
    }
    
    func setNumberOfPersonsField() {
        self.numOfPersonsTextLabel.text = "Sastojci potrebni za \(self.localNumberOfPersons) " + self.correctFormOFString()
        
        self.decreaseNumOfPersons.isEnabled = self.localNumberOfPersons != 0
    }
    
    func correctFormOFString() -> String {
        switch self.localNumberOfPersons {
        case 1:
            return "osobu"
        case 2..<5:
            return "osobe"
        default:
            return "osoba"
        }
    }
    
    @IBAction func decreaseNumOfPersonsButtonClicked(_ sender: Any) {
        self.localNumberOfPersons -= 1
        self.updateIngredientsQuantity()
        self.setNumberOfPersonsField()
    }
    
    @IBAction func increaseNumOfPersonsButtonClicked(_ sender: Any) {
        self.localNumberOfPersons += 1
        self.updateIngredientsQuantity()
        self.setNumberOfPersonsField()
    }
    
    func updateIngredientsQuantity() {
        for (indexList, ingredient) in self.recipe.ingredients.enumerated() {
            let forDelt = Double(self.localNumberOfPersons) / Double(self.recipe.numOfPersons)
            self.localArrayOfIngredients[indexList].quantity = ingredient.quantity * forDelt
        }
        self.tableView.reloadData()
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
        return (section == 0 ? self.recipe.ingredients.count : self.recipe.steps.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let wantedList = indexPath.section == 0 ? self.localStringIngredients : self.recipe.steps
        
        if indexPath.section != 0 || self.recipe.ingredients[indexPath.row].quantity != 0 {
            cell.textLabel?.text = wantedList[indexPath.row]
        }
        return cell
    }
    
    
}
