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

enum RecipeShowType : Int, CaseIterable {
    case List, Grid, LargeGrid
}

enum UserDefaultsKeys : String {
    case ShowingType
}

class GeneralViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addNewRecipeButton: UIButton!
    @IBOutlet weak var searchBarButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var changeShowTypeButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var clearCategoryButton: UIButton!
    
    var addNewRecipeViewController: AddNewRecipeViewController?
    var isFavorites: Bool
    var isMyRecipes: Bool
    
    var recipes: [Recipe] = []
    var unfilteredRecipes: [Recipe] = []
    var unsortedRecipes: [Recipe] = []
    var categoryRecipes: [Recipe] = []
    
    var recipeShwoingType: RecipeShowType = .List
    var categoryPicked: RecipeCategory?
    var refreshControl: UIRefreshControl?
    var collectionRefreshControl: UIRefreshControl?
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
        
        if Datafeed.shared.recipes.isEmpty {
            Datafeed.shared.recipeRepository.getRecipes()
        }
        
        self.searchBar.placeholder = "Pretraži recepte"
        self.searchBar.delegate = self
        self.searchBar.isHidden = true
        
        self.searchBarButton.setTitle("", for: .normal)
        
        self.categoryButton.setTitle("Izaberi kategoriju", for: .normal)
        self.changeShowTypeButton.setTitle(" Izaberi prikaz", for: .normal)
        
        [self.categoryButton, self.changeShowTypeButton, self.searchBarButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeCell")
        self.tableView.register(UINib(nibName: "RecipeImageTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeImageCell")
        self.tableView.register(UINib(nibName: "RecipeTableViewHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "RecipeHeaderCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "RecipeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeCollectionViewCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        self.refreshControl!.tintColor = AppTheme.textUniversalGreen
        self.tableView.refreshControl = self.refreshControl!

        self.collectionRefreshControl = UIRefreshControl()
        self.collectionRefreshControl!.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        self.collectionRefreshControl!.tintColor = AppTheme.textUniversalGreen
        self.collectionView.refreshControl = self.collectionRefreshControl!
        
        self.addNewRecipeButton.isHidden = !self.isMyRecipes
        self.clearCategoryButton.isHidden = true
        self.clearCategoryButton.setTitle("Poništi", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserDefaultsData()
        self.loadShowingType()
        
        self.setColor()
        self.recipes =  self.isFavorites ? Datafeed.shared.favRecipes : self.isMyRecipes ? Datafeed.shared.myRecipes : Datafeed.shared.recipes
        self.unfilteredRecipes = self.recipes
        self.unsortedRecipes = self.recipes
        self.sortData()
        
//        self.tableView.isHidden = true
//        self.collectionView.isHidden = false
    }
    
    private func loadUserDefaultsData() {
        let selectedTypeRawValue = UserDefaults.standard.integer(forKey: UserDefaultsKeys.ShowingType.rawValue)
        self.recipeShwoingType = RecipeShowType(rawValue: selectedTypeRawValue) ?? .List
        self.changeRecipeShowingTypeButtonImage()
    }
    
    private func loadShowingType() {
        switch self.recipeShwoingType {
        case .List:
            self.tableView.isHidden = false
            self.collectionView.isHidden = true
        case .Grid, .LargeGrid:
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
        default:
            ()
        }
    }
    
    func setColor() {
        [self.categoryButton, self.changeShowTypeButton, self.searchBarButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
        [self.addNewRecipeButton, self.clearCategoryButton, self.searchBarButton, self.changeShowTypeButton].forEach {
            $0?.tintColor = AppTheme.setTextColor()
        }
        self.navigationController?.navigationBar.tintColor = AppTheme.setTextColor()
        (self.searchBar?.value(forKey: "cancelButton") as? UIButton)?.tintColor = AppTheme.setTextColor()
    }
    
    // Device color appearance has changed (light/dark)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColor()
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    @objc func refreshTable() {
        Datafeed.shared.recipeRepository.getRecipes()
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
        categoryPickerViewController.tag = 1
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
            
            self.searchBarButton.isEnabled = false
            self.searchBarButton.backgroundColor = .gray
            self.searchBarButton.layer.borderColor = UIColor.gray.cgColor
        }))
        alert.addAction(UIAlertAction(title: "Poništi", style: .cancel, handler: {_ in
            self.filterByCategoryCanceled()
        }))
//        self.categoryPicked = .coldSideDish
        self.present(alert, animated: true, completion: nil)
    }
    
    func setCategoryButtonTitle() -> String {
        return Datafeed.shared.recipeCategoryName(currentCategory: self.categoryPicked)
    }
    
    @IBAction func clearCategoryButtonClicked(_ sender: Any) {
        self.filterByCategoryCanceled()
        
        self.searchBarButton.isEnabled = true
        self.searchBarButton.backgroundColor = AppTheme.setBackgroundColor()
        self.searchBarButton.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
    }
    
    func filterByCategoryCanceled() {
        self.categoryPicked = nil
        self.recipes = self.unfilteredRecipes
        self.unsortedRecipes = self.unfilteredRecipes
        self.categoryButton.setTitle(self.setCategoryButtonTitle(), for: .normal)
        self.clearCategoryButton.isHidden = true
//        self.searchBar.isHidden = false
        self.sortData()
    }
    
    @IBAction func changeShowTypeButtonClicked(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 200)
        let showTypePickerViewController = UIPickerView(frame: CGRect(x: -60, y: 0, width: 400, height: 200))
        showTypePickerViewController.delegate = self
        showTypePickerViewController.dataSource = self
        showTypePickerViewController.tag = 2
        showTypePickerViewController.selectRow(self.recipeShwoingType.rawValue, inComponent: 0, animated: true)
        vc.view.addSubview(showTypePickerViewController)
        
        let alert = UIAlertController(title: "Izaberi način prikaza recepata", message: "", preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Izaberi", style: .default, handler: {_ in
        
//        self.changeRecipeShowingType()
        
            switch self.recipeShwoingType {
            case .List:
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
                self.tableView.reloadData()
            case .Grid, .LargeGrid:
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }
            
            UserDefaults.standard.set(self.recipeShwoingType.rawValue, forKey: UserDefaultsKeys.ShowingType.rawValue)
        
            self.changeRecipeShowingTypeButtonImage()
        }))
        alert.addAction(UIAlertAction(title: "Poništi", style: .cancel, handler: nil))
//        self.recipeShwoingType = .List
        self.present(alert, animated: true, completion: nil)
    }
    
    private func changeRecipeShowingType() {
        switch self.recipeShwoingType {
        case .List:
            self.recipeShwoingType = .Grid
        case .Grid:
            self.recipeShwoingType = .LargeGrid
        case .LargeGrid:
            self.recipeShwoingType = .List
        }
    }
    
    private func changeRecipeShowingTypeButtonImage() {
        switch self.recipeShwoingType {
        case .List:
            self.changeShowTypeButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        case .Grid:
            self.changeShowTypeButton.setImage(UIImage(systemName: "square.grid.3x3.fill"), for: .normal)
        case .LargeGrid:
            self.changeShowTypeButton.setImage(UIImage(systemName: "square.grid.2x2.fill"), for: .normal)
        }
    }
    
    @IBAction func searchBarButtonClicked(_ sender: Any) {
        self.searchBar.isHidden = !self.searchBar.isHidden
    }
}

//MARK: - UITableViewDataSource
extension GeneralViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipeShwoingType == .List ? self.recipes.count : self.recipes.count/2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.recipeShwoingType == .List {
            return self.recipeListTypeCell(tableView, cellForRowAt: indexPath)
        }
        else {
            return self.recipeGridTypeCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.recipeShwoingType == .List ? 40 : 200
    }
    
    func recipeListTypeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell") as! RecipeTableViewCell

        let record = self.recipes[indexPath.row]

        cell.titleLabel?.text = record.name
        cell.titleLabel?.textColor = AppTheme.setTextColor()
        cell.prepTimeLabel.text = "\(record.prepTime + record.cookTime) minuta"
        cell.prepTimeLabel.textColor = AppTheme.setTextColor()
        cell.prepTimeLabel.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .black)

        var recipeImage = UIImage(named: record.imageName)
        if recipeImage == nil, let imageData = UserDefaults(suiteName: Datafeed.shared.kAppGroup)?.object(forKey: record.imageName) as? Data {
            recipeImage = UIImage(data: imageData)
        }
        
        return cell
    }
    
    func recipeGridTypeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeImageCell") as! RecipeImageTableViewCell
        
        let firstRecord = self.recipes[indexPath.row * 2]
        let secondRecord = self.recipes[indexPath.row * 2 + 1]
        
        cell.recipeLeftImageView.image = UIImage(named: firstRecord.imageName)
        cell.recipeRightImageView.image = UIImage(named: secondRecord.imageName)
        
        cell.recipeLeftLabel.text = firstRecord.name
        cell.recipeLeftLabel.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)
        
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
        guard self.recipeShwoingType == .List else {
            return nil
        }
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RecipeHeaderCell") as! RecipeTableViewHeaderCell

        cell.delegate = self
        [cell.titleLabel, cell.prepTimeLabel].forEach {
            $0?.textColor = AppTheme.setTextColor()
        }
        cell.sortArrowImage.tintColor = AppTheme.setTextColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.recipeShwoingType == .List ? 45.0 : 0.0
    }
}

//MARK: - UICollectionViewDataSource
extension GeneralViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCollectionViewCell", for: indexPath) as? RecipeCollectionViewCell
        let record = self.recipes[indexPath.row]
        
        if let recipeImage = UIImage(named: record.imageName) {
            cell?.recipeImageView.image = recipeImage
            cell?.recipeImageView.contentMode = .scaleAspectFill
        }
        else {
            cell?.recipeImageView.image = UIImage(systemName: "photo")
            cell?.recipeImageView.contentMode = .scaleAspectFit
            cell?.recipeImageView.tintColor = AppTheme.backgroundUniversalGreen
        }
        
        cell?.recipeNameLabel.text = record.name
        cell?.recipeNameLabel.font = .systemFont(ofSize: 16.0, weight: .bold)
        cell?.recipeNameLabel.textColor = .white
        cell?.recipeNameLabel.backgroundColor = AppTheme.backgroundUniversalGreen.withAlphaComponent(0.65)
        
        cell?.layer.borderWidth = 0.5
        cell?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        
        return cell ?? UICollectionViewCell()
    }
}

//MARK: - UICollectionViewDelegate
extension GeneralViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: false)
        let destination = RecipeDetailViewController(recipe: self.recipes[indexPath.row])
        self.navigationController?.pushViewController(destination, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension GeneralViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.recipeShwoingType == .LargeGrid ?
            CGSize(width: (self.view.frame.width-4)/2.1, height: self.view.frame.height/3) :
            CGSize(width: (self.view.frame.width-4)/3.2, height: self.view.frame.height/5 - 5)
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
        case .Unsorted:
            self.recipes = self.unsortedRecipes
        }
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}

//MARK: - NewRecipeViewControllerDelegate
extension GeneralViewController : NewRecipeViewControllerDelegate {
    func didAddNewRecipe(_ controller: AddNewRecipeViewController, newRecipe: Recipe) {
        Datafeed.shared.recipes.append(newRecipe)
        Datafeed.shared.recipeRepository.addRecipe(newRecipe)
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
        self.recipes = self.isFavorites ? Datafeed.shared.favRecipes : self.isMyRecipes ? Datafeed.shared.myRecipes : Datafeed.shared.recipes
        self.unfilteredRecipes = self.recipes
        self.unsortedRecipes = self.recipes
        self.sortData()
        self.tableView.reloadData()
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
        self.collectionRefreshControl?.endRefreshing()
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
        // Category picker view
        if pickerView.tag == 1 {
            let category = RecipeCategory(rawValue: row) ?? .snack
            return Datafeed.shared.recipeCategoryName(currentCategory: category)
        }
        // Show type picker view
        else if pickerView.tag == 2 {
            switch row {
            case 0:
                return "Lista"
            case 1:
                return "Slike"
            case 2:
                return "Velike Slike"
            default:
                return "Slike" //TODO: change this title to something with more sense
            }
        }
        // Default case
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Category picker view
        if pickerView.tag == 1 {
            self.categoryPicked = RecipeCategory(rawValue: row) ?? .snack
        }
        // Show type picker view
        else if pickerView.tag == 2 {
            self.recipeShwoingType = RecipeShowType(rawValue: row) ?? .List
        }
        // Default case
        return
    }
}

//MARK: - UIPickerViewDataSource
extension GeneralViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? RecipeCategory.allCases.count : RecipeShowType.allCases.count
    }
}
