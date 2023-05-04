//
//  MoreViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

//MARK: - UITableViewDataSource
extension MoreViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var contentConfiguration = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            contentConfiguration.text = "Ulogujte se"
        case 1:
            contentConfiguration.text = "Napravite nalog"
        default:
            contentConfiguration.text = "Ulogujte se"
        }
        
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MoreViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 0:
            self.showLogin()
        case 1:
            self.showSignin()
        default:
            return
        }
    }
}

//MARK: - AccountViewController calling
extension MoreViewController {
    private func showLogin() {
        let accountViewController = AccountViewController(isSignUp: false)
        accountViewController.modalPresentationStyle = .popover
        self.present(accountViewController, animated: true)
    }
    
    private func showSignin() {
        let accountViewController = AccountViewController(isSignUp: true)
        accountViewController.modalPresentationStyle = .popover
        self.present(accountViewController, animated: true)
    }
}
