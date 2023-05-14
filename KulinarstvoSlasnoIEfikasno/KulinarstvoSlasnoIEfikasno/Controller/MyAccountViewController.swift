//
//  MyAccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import UIKit
import Firebase

let kImageCache = NSCache<AnyObject, AnyObject>()

class MyAccountViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var usernameValueLabel: UILabel!
    @IBOutlet weak var telephoneNumberTextLabel: UILabel!
    @IBOutlet weak var telephoneNumberValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userImageView.layer.borderWidth = 1
        self.userImageView.layer.masksToBounds = false
        self.userImageView.layer.borderColor = UIColor.black.cgColor
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.clipsToBounds = true
        
        self.emailTextLabel.text = "E-mail adresa"
        self.emailValueLabel.text = Auth.auth().currentUser?.email ?? "E-mail adresa ne postoji"
        self.nameTextLabel.text = "Ime i prezime"
        self.nameValueLabel.text = Auth.auth().currentUser?.displayName ?? "Ime i prezime ne postoje"
        self.usernameTextLabel.text = "Korisnicko ime"
        self.usernameValueLabel.text = Auth.auth().currentUser?.displayName ?? "Korisnicko ime ne postoji"
        self.telephoneNumberTextLabel.text = "Broj telefona"
        self.telephoneNumberValueLabel.text = Auth.auth().currentUser?.phoneNumber ?? "Broj telefona ne postoji"
        
        self.getUserProfileImage()
    }
    
    func getUserProfileImage() {
        guard let imageUrl = Auth.auth().currentUser?.photoURL else {
            return
        }
        
        if let imageFromCache = kImageCache.object(forKey: imageUrl as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.userImageView.image = imageFromCache
            }
            return
        }
        
        let downloadTask = URLSession.shared.dataTask(with: imageUrl, completionHandler: { [weak self] (data, response, error) in
            guard let imageData = data, let profileImage = UIImage(data: imageData) else {
                return
            }
            
            kImageCache.setObject(profileImage, forKey: imageUrl as AnyObject)
            
            DispatchQueue.main.async {
                self?.userImageView.image = profileImage
            }
        })
        
        downloadTask.resume()
    }
}
