//
//  GeneralViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

enum SortByPrepTime {
    case Unsorted, Ascending, Descending
}

class GeneralViewController: UIViewController {
    
    var addNewRecipeViewController: AddNewRecipeViewController?
    
    var isFavorites: Bool
    var isMyRecipes: Bool
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var clearCategoryButton: UIButton!
    
    var recipes: [Recipe] = []
    var unfilteredRecipes: [Recipe] = []
    var unsortedRecipes: [Recipe] = []
    var categoryRecipes: [Recipe] = []
    
    var categoryPicked: RecipeCategory?
    
    var refreshControl: UIRefreshControl?
    
    var sortByPrepTime = SortByPrepTime.Unsorted
    
    var oldSearchText = ""
    
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
        
        self.searchBar.placeholder = "Pretraži recepte"
        self.searchBar.delegate = self
        
        self.categoryButton.setTitle("Izaberi kategoriju", for: .normal)
        
        self.categoryButton.layer.cornerRadius = 10
        self.categoryButton.layer.borderWidth = 2
        self.categoryButton.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        self.tableView.register(UINib(nibName: "RecipeTableViewHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "RecipeHeaderCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        self.refreshControl!.tintColor = AppTheme.textUniversalGreen
        self.tableView.refreshControl = self.refreshControl!
        
        self.addNewRecipeButton.isHidden = !self.isMyRecipes
        self.clearCategoryButton.isHidden = true
        self.clearCategoryButton.setTitle("Poništi", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setColor()
        self.recipes =  self.isFavorites ? Datafeed.shared.favRecipes : self.isMyRecipes ? Datafeed.shared.myRecipes : Datafeed.shared.recipes
        self.unfilteredRecipes = self.recipes
        self.unsortedRecipes = self.recipes
        self.sortData()
    }
    
    func setColor() {
        self.categoryButton.backgroundColor = AppTheme.setBackgroundColor()
        self.categoryButton.setTitleColor(AppTheme.setTextColor(), for: .normal)
        self.addNewRecipeButton.tintColor = AppTheme.setTextColor()
        self.clearCategoryButton.tintColor = AppTheme.setTextColor()
        self.navigationController?.navigationBar.tintColor = AppTheme.setTextColor()
        (self.searchBar?.value(forKey: "cancelButton") as? UIButton)?.tintColor = AppTheme.setTextColor()
    }
    
    // Device color appearance has changed (light/dark)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColor()
        self.tableView.reloadData()
    }
    
    @objc func refreshTable() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
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
        alert.addAction(UIAlertAction(title: "Sačuvaj", style: .default, handler: {_ in
            // Select category action is applied to both recipes array and unsorted recipes array
            self.categoryRecipes = []
            self.recipes = self.unfilteredRecipes
            self.categoryRecipes = self.recipes.filter {
                $0.category == self.categoryPicked
            }
            self.unsortedRecipes = self.unfilteredRecipes.filter {
                $0.category == self.categoryPicked
            }
            self.recipes = self.categoryRecipes
            self.categoryButton.setTitle(self.setCategoryButtonTitle(), for: .normal)
            self.clearCategoryButton.isHidden = false
            self.searchBar.isHidden = true
            self.sortData()
            
            self.searchBar.resignFirstResponder()
            if self.oldSearchText.count == 0 {
                self.searchBar.showsCancelButton = false
            }
        }))
        alert.addAction(UIAlertAction(title: "Poništi", style: .cancel, handler: {_ in
            self.filterByCategoryCanceled()
        }))
        self.categoryPicked = .coldSideDish
        self.present(alert, animated: true, completion: nil)
    }
    
    func setCategoryButtonTitle() -> String {
        return Datafeed.shared.recipeCategoryName(currentCategory: self.categoryPicked)
    }
    
    @IBAction func clearCategoryButtonClicked(_ sender: Any) {
        self.filterByCategoryCanceled()
    }
    
    func filterByCategoryCanceled() {
        self.categoryPicked = nil
        self.recipes = self.unfilteredRecipes
        self.unsortedRecipes = self.unfilteredRecipes
        self.categoryButton.setTitle(self.setCategoryButtonTitle(), for: .normal)
        self.clearCategoryButton.isHidden = true
        self.searchBar.isHidden = false
        self.sortData()
    }
}

//MARK: - UITableViewDataSource
extension GeneralViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let recipesCount = self.recipes.count
//        if recipesCount == 0 {
//            self.recipes = self.categoryPicked == nil ? self.unfilteredRecipes : self.categoryRecipes
//        }
        return recipesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell
        
        let record = self.recipes[indexPath.row]
        
        cell.titleLabel?.text = record.name
        cell.titleLabel?.textColor = AppTheme.setTextColor()
        cell.prepTimeLabel.text = "\(record.prepTime + record.cookTime)"
        cell.prepTimeLabel.textColor = AppTheme.setTextColor()
        
        var recipeImage = UIImage(named: record.imageName)
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: record.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }
        cell.recipeImageView.image = recipeImage
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension GeneralViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let destination = RecipeDetailViewController(recipe: self.recipes[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RecipeHeaderCell") as! RecipeTableViewHeaderCell

        cell.delegate = self
        [cell.titleLabel, cell.prepTimeLabel, cell.imageLabel].forEach {
            $0?.textColor = AppTheme.setTextColor()
        }
        cell.sortArrowImage.tintColor = AppTheme.setTextColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
}

//MARK: - RecipeTableViewHeaderCellDelegate
extension GeneralViewController : RecipeTableViewHeaderCellDelegate {
    func prepTimeSortClicked(headerCell: RecipeTableViewHeaderCell) {
        self.sortByPrepTime = {
            switch self.sortByPrepTime {
            case .Ascending:
                headerCell.sortArrowImage.image = UIImage(systemName: "arrowtriangle.down")
                return .Descending
            case .Descending:
                headerCell.sortArrowImage.image = UIImage(systemName: "arrow.up.and.down.circle")
                return .Unsorted
            case .Unsorted:
                headerCell.sortArrowImage.image = UIImage(systemName: "arrowtriangle.up")
                return .Ascending
            }
        }()
        self.sortData()
    }
    
    func sortData() {
        switch self.sortByPrepTime {
        case .Ascending:
            self.recipes.sort(by: {
                return ($0.prepTime + $0.cookTime) < ($1.prepTime + $1.cookTime)
            })
        case .Descending:
            self.recipes.sort(by: {
                return ($0.prepTime + $0.cookTime) > ($1.prepTime + $1.cookTime)
            })
        case .Unsorted:()
            self.recipes = self.unsortedRecipes
        }
        self.tableView.reloadData()
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
    
    func didEditRecipe(_ controller: AddNewRecipeViewController, oldRecipe: Recipe, newRecipe: Recipe) {
        
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
        if self.oldSearchText.count > searchText.count {
            self.recipes = self.unfilteredRecipes
        }
        self.oldSearchText = searchText
        
        guard searchText.count != 0 else {
            self.categoryButton.isHidden = false
            self.unsortedRecipes = self.unfilteredRecipes
            self.sortData()
            return
        }
        
        self.categoryButton.isHidden = true
        
        self.recipes = self.recipes.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        self.unsortedRecipes = self.unfilteredRecipes.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        
        self.sortData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        let searchBarCancelButton = self.searchBar.value(forKey: "cancelButton") as! UIButton
        searchBarCancelButton.tintColor = AppTheme.setTextColor()
        searchBarCancelButton.setTitle("Poništi", for: .normal)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if self.oldSearchText.count == 0 {
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.recipes = self.unfilteredRecipes
        self.unsortedRecipes = self.unfilteredRecipes
        self.categoryButton.isHidden = false
        self.sortData()
    }
}

//MARK: - UIPickerViewDelegate
extension GeneralViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = RecipeCategory(rawValue: row) ?? .snack
        return Datafeed.shared.recipeCategoryName(currentCategory: category)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryPicked = RecipeCategory(rawValue: row) ?? .snack
    }
}

//MARK: - UIPickerViewDataSource
extension GeneralViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeCategory.allCases.count
    }
}
