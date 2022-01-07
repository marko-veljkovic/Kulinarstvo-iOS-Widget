//
//  GeneralViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class GeneralViewController: UIViewController {
    
    var addNewRecipeViewController: AddNewRecipeViewController?
    
    var isFavorites: Bool
    var isMyRecipes: Bool
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryButton: UIButton!
    
    var recipes: [Recipe] = []
    var unfilteredRecipes: [Recipe] = []
    var categoryRecipes: [Recipe] = []
    
    var categoryPicked: RecipeCategory?
    
    init(isFavorites: Bool = false, isMyRecipes: Bool = false) {
        self.isFavorites = isFavorites
        self.isMyRecipes = isMyRecipes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Datafeed.shared.delegate = self
        
        if !Datafeed.shared.recipeModel.isLoaded {
            Datafeed.shared.recipeModel.loadFile()
        }
        
        self.searchBar.placeholder = "Pretrazi recepte"
        self.searchBar.delegate = self
        
        self.categoryButton.setTitle("Izaberi kategoriju", for: .normal)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        
        self.addNewRecipeButton.isHidden = !self.isMyRecipes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.recipes =  self.isFavorites ? Datafeed.shared.favRecipes : self.isMyRecipes ? Datafeed.shared.myRecipes : Datafeed.shared.recipes
        self.unfilteredRecipes = self.recipes
    }
    
    @IBAction func addNewRecipeButtonClicked(_ sender: Any) {
        self.addNewRecipeViewController = AddNewRecipeViewController()
        self.addNewRecipeViewController?.delegate = self
        
        self.navigationController?.pushViewController(self.addNewRecipeViewController!, animated: true)
    }
    
    @IBAction func categoryButtonClicked(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 200)
        let categoryPickerViewController = UIPickerView(frame: CGRect(x: -60, y: 0, width: 400, height: 200))
        categoryPickerViewController.delegate = self
        categoryPickerViewController.dataSource = self
        vc.view.addSubview(categoryPickerViewController)
        
        let alert = UIAlertController(title: "Izaberi kategoriju recepata", message: "", preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Sacuvaj", style: .default, handler: {_ in
            self.categoryRecipes = []
            self.recipes = self.unfilteredRecipes
            self.categoryRecipes = self.recipes.filter {
                $0.category == self.categoryPicked
            }
            self.recipes = self.categoryRecipes
            self.tableView.reloadData()
            self.categoryButton.setTitle(self.setCategoryButtonTitle(), for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Ponisti", style: .cancel, handler: {_ in
            self.categoryPicked = nil
            self.recipes = self.unfilteredRecipes
            self.tableView.reloadData()
            self.categoryButton.setTitle(self.setCategoryButtonTitle(), for: .normal)
        }))
        self.categoryPicked = .coldSideDish
        self.present(alert, animated: true, completion: nil)
    }
    
    func setCategoryButtonTitle() -> String {
        switch self.categoryPicked {
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
        default:
            return "Izaberi kategoriju"
        }
    }
}

//MARK: - UITableViewDataSource
extension GeneralViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let recipesCount = self.recipes.count
        if recipesCount == 0 {
            self.recipes = self.categoryPicked == nil ? self.unfilteredRecipes : self.categoryRecipes
        }
        return recipesCount
        //self.isFavorites ? Datafeed.shared.favRecipes.count : self.isMyRecipes ? Datafeed.shared.myRecipes.count : Datafeed.shared.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
        
        let record = self.recipes[indexPath.row]
        //self.isFavorites ? Datafeed.shared.favRecipes[indexPath.row] :
                     //self.isMyRecipes ? Datafeed.shared.myRecipes[indexPath.row] :
                       //                 Datafeed.shared.recipes[indexPath.row]
        
        cell.title?.text = record.name
        var recipeImage = UIImage(named: record.imageName)
        
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: record.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }
            
        cell.recipeImageView.image = recipeImage //UIImage(named: record.imageName)
        
        // Restart recipes array when user delete one or more characters from search bar
        if indexPath.row == (self.tableView.numberOfRows(inSection: 0) - 1) {
            self.recipes = self.categoryPicked == nil ? self.unfilteredRecipes : self.categoryRecipes
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension GeneralViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let destination = RecipeDetailViewController(recipe: self.recipes[indexPath.row])
        //RecipeDetailViewController(recipe: self.isFavorites ? Datafeed.shared.favRecipes[indexPath.row] : self.isMyRecipes ? Datafeed.shared.myRecipes[indexPath.row] : Datafeed.shared.recipes[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
    }
}

//MARK: - NewRecipeViewControllerDelegate
extension GeneralViewController : NewRecipeViewControllerDelegate {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe) {
        Datafeed.shared.recipes.append(newRecipe)
    }
    
    func controllerIsDismissed(_ controller: AddNewRecipeViewController) {
        self.addNewRecipeViewController = nil
    }
}

//MARK: - DatafeedDelegate
extension GeneralViewController : DatafeedDelegate {
    func recipesDataParsed() {
        self.tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension GeneralViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.recipes = self.recipes.filter {
            $0.name.prefix(searchText.count) == searchText
        }
        
        self.tableView.reloadData()
    }
}

extension GeneralViewController : UIPickerViewDelegate {
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
        self.categoryPicked = RecipeCategory(rawValue: row) ?? .snack
    }
}

extension GeneralViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeCategory.allCases.count
    }
}
