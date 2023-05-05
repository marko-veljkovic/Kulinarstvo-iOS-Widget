//
//  MyAccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import UIKit
import Firebase

class MyAccountViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailLabel.text = Auth.auth().currentUser?.email ?? "Greska"
    }



}
