//
//  TabBarViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let generalNavigationController: UINavigationController = {
        let generalViewController = GeneralViewController()
        generalViewController.navigationItem.title = "Pregled"
        let navigationController = UINavigationController(rootViewController: generalViewController)
        navigationController.title = "Pregled"
        navigationController.tabBarItem.image = UIImage(systemName: "list.dash")
        return navigationController
    }()
    
    let favoritesNavigationController: UINavigationController = {
        let favoritesViewController = GeneralViewController(isFavorites: true)
        favoritesViewController.navigationItem.title = "Omiljeni recepti"
        let navigationController = UINavigationController(rootViewController: favoritesViewController)
        navigationController.title = "Omiljeni recepti"
        navigationController.tabBarItem.image = UIImage(systemName: "star.fill")
        return navigationController
    }()
    
    let myRecipesNavigationController: UINavigationController = {
        let myRecipesViewController = GeneralViewController(isMyRecipes: true)
        myRecipesViewController.navigationItem.title = "Moji recepti"
        let navigationController = UINavigationController(rootViewController: myRecipesViewController)
        navigationController.title = "Moji recepti"
        navigationController.tabBarItem.image = UIImage(systemName: "person.fill")
        return navigationController
    }()
    
//    let accountViewController: UINavigationController = {
//        let accountViewController = AccountViewController()
//        accountViewController.navigationItem.title = "Moji nalog"
//        let navigationController = UINavigationController(rootViewController: accountViewController)
//        navigationController.title = "Moji nalog"
//        navigationController.tabBarItem.image = UIImage(systemName: "person.circle.fill")
//        return navigationController
//    }()
    
    let moreViewController: UINavigationController = {
        let moreViewController = MoreViewController()
        moreViewController.navigationItem.title = "Vise"
        let navigationController = UINavigationController(rootViewController: moreViewController)
        navigationController.title = "Vise"
        navigationController.tabBarItem.image = UIImage(systemName: "line.3.horizontal")
        return navigationController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [generalNavigationController, favoritesNavigationController, myRecipesNavigationController, moreViewController]
        
        self.tabBar.tintColor = self.traitCollection.userInterfaceStyle == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tabBar.tintColor = self.traitCollection.userInterfaceStyle == .dark ? AppTheme.textUniversalGreen : AppTheme.backgroundUniversalGreen
    }
    
    func generate(vc: UIViewController, title: String, imageName: String) -> UINavigationController {
        vc.navigationItem.title = title
        let navC = UINavigationController(rootViewController: vc)
        navC.title = title
        navC.tabBarItem.image = UIImage(systemName: imageName)
        return navC
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Pregled" {
            (self.generalNavigationController.topViewController as? GeneralViewController)?.tableView.reloadData()
        }
    }
    
}
