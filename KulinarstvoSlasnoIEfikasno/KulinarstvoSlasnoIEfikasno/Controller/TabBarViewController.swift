//
//  TabBarViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 31.10.21.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var generalNavigationController: UINavigationController = {
        let generalViewController = GeneralViewController(isFavorites: false)
        generalViewController.navigationItem.title = "Predled"
        let navigationController = UINavigationController(rootViewController: generalViewController)
        navigationController.title = "Pregled"
        navigationController.tabBarItem.image = UIImage(systemName: "list.dash")
        return navigationController
    }()
    
    var favoritesNavigationController: UINavigationController = {
        let favoritesViewController = GeneralViewController(isFavorites: true)
        favoritesViewController.navigationItem.title = "Omiljeno"
        let navigationController = UINavigationController(rootViewController: favoritesViewController)
        navigationController.title = "Omiljeno"
        navigationController.tabBarItem.image = UIImage(systemName: "star.fill")
        return navigationController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [generalNavigationController, favoritesNavigationController]
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
