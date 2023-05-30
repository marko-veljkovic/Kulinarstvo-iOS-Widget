//
//  MyAccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 4.5.23.
//

import UIKit
import Firebase

let kImageCache = NSCache<AnyObject, AnyObject>()

protocol MyAccountViewControllerDelegate: AnyObject {
    func myAccountViewControllerChangeDataButtonClicked(_ controller: MyAccountViewController)
    func myAccountViewControllerChangePasswordButtonClicked(_ controller: MyAccountViewController)
}

class MyAccountViewController: UIViewController {

    @IBOutlet weak var changeDataButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var usernameValueLabel: UILabel!
    @IBOutlet weak var telephoneNumberTextLabel: UILabel!
    @IBOutlet weak var telephoneNumberValueLabel: UILabel!
    
    weak var delegate: MyAccountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [self.nameValueLabel, self.usernameValueLabel, self.emailValueLabel, self.telephoneNumberValueLabel].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.setBackgroundColor().cgColor
        }
        
        self.changeDataButton.setTitle("Promeni podatke", for: .normal)
        self.changePasswordButton.setTitle("Promeni lozniku", for: .normal)
        
        self.setImage()
        self.setColors()
        self.getUserProfileImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    
    private func reloadData() {
        if let currentEmail = Auth.auth().currentUser?.email, !currentEmail.isEmpty {
            self.emailTextLabel.text = "E-mail adresa"
            self.emailValueLabel.text = currentEmail
        }
        else {
            self.emailTextLabel.isHidden = true
            self.emailValueLabel.isHidden = true
        }
        
        if let currentName = Datafeed.shared.currentUser?.name, let currentSurname = Datafeed.shared.currentUser?.surname, !currentName.isEmpty, !currentSurname.isEmpty {
            self.nameTextLabel.text = "Ime i prezime"
            self.nameValueLabel.text = currentName + " " + currentSurname
        }
        else if let onlyCurrentName = Datafeed.shared.currentUser?.name, !onlyCurrentName.isEmpty {
            self.nameTextLabel.text = "Ime"
            self.nameValueLabel.text = onlyCurrentName
        }
        else if let onlyCurrentSurname = Datafeed.shared.currentUser?.surname, !onlyCurrentSurname.isEmpty {
            self.nameTextLabel.text = "Prezime"
            self.nameValueLabel.text = onlyCurrentSurname
        }
        else {
            self.nameTextLabel.isHidden = true
            self.nameValueLabel.isHidden = true
        }
        
        if let currentUsername = Datafeed.shared.currentUser?.nickname, !currentUsername.isEmpty {
            self.usernameTextLabel.text = "Korisnicko ime"
            self.usernameValueLabel.text = currentUsername
        }
        else {
            self.usernameTextLabel.isHidden = true
            self.usernameValueLabel.isHidden = true
        }
        
        //TODO: Add phone number to users data if needed
        self.telephoneNumberTextLabel.text = "Broj telefona"
        self.telephoneNumberValueLabel.text = Auth.auth().currentUser?.phoneNumber ?? "Broj telefona ne postoji"
        self.telephoneNumberTextLabel.isHidden = true
        self.telephoneNumberValueLabel.isHidden = true
    }
    
    @IBAction func changeDataButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.myAccountViewControllerChangeDataButtonClicked(self)
    }
    
    @IBAction func changePasswordButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.myAccountViewControllerChangePasswordButtonClicked(self)
    }
    
    private func setImage() {
        self.userImageView.layer.borderWidth = 1
        self.userImageView.layer.masksToBounds = false
        self.userImageView.layer.borderColor = UIColor.black.cgColor
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        self.userImageView.clipsToBounds = true
        self.userImageView.contentMode = .scaleAspectFill
        self.userImageView.tintColor = AppTheme.setTextColor()
        self.userImageView.backgroundColor = AppTheme.setBackgroundColor()
    }
    
    private func setColors() {
        [self.changeDataButton, self.changePasswordButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        [self.changeDataButton, self.changePasswordButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
            $0?.tintColor = AppTheme.setTextColor()
        }
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
