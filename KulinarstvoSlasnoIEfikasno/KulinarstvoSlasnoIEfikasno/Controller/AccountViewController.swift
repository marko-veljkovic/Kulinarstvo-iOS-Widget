//
//  AccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 25.4.23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

protocol AccountViewControllerDelegate : AnyObject {
    func userLoggedInSuccesfully(_ controller: AccountViewController)
    func userPhotoUrlSuccesfullySaved(_ controller: AccountViewController)
}

class AccountViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    
    weak var delegate: AccountViewControllerDelegate?
    
    var isSingUp: Bool = false
    let storageRef = Storage.storage().reference(forURL: "gs://culinary-dande.appspot.com")
    
    init(isSignUp: Bool) {
        self.isSingUp = isSignUp
        super.init(nibName: "AccountViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailLabel.text = "E-mail"
        self.emailTextField.placeholder = "Unesite e-mail adresu"
        self.passwordLabel.text = "Lozinka"
        self.passwordTextField.placeholder = "Unesite lozinku"
        self.repeatPasswordLabel.text = "Potvrda lozinke"
        self.repeatPasswordTextField.placeholder = "Ponovo unesite lozinku"
        self.nameLabel.text = "Ime"
        self.nameTextField.placeholder = "Unesite ime"
        self.surnameLabel.text = "Prezime"
        self.surnameTextField.placeholder = "Unesite prezime"
        self.nicknameLabel.text = "Korisničko ime"
        self.nicknameTextField.placeholder = "Unesite korisničko ime"
        
        self.loginButton.setTitle(self.isSingUp ? "Napravite nalog" : "Ulogujte se", for: .normal)
        self.profileImageButton.setTitle("Izaberite profilnu sliku", for: .normal)
        
        self.profileImageView.isHidden = true
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.black.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
        [self.repeatPasswordLabel, self.repeatPasswordTextField, self.profileImageButton, self.nameLabel, self.nameTextField, self.surnameLabel, self.surnameTextField, self.nicknameLabel, self.nicknameTextField].forEach {
            $0?.isHidden = !self.isSingUp
        }
        
        [self.passwordTextField, self.repeatPasswordTextField].forEach {
            $0?.isSecureTextEntry = true
        }
        
        [self.emailTextField, self.nameTextField, self.surnameTextField, self.passwordTextField, self.repeatPasswordTextField, self.nicknameTextField].forEach {
            $0?.delegate = self
        }
        
        self.setColors()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // Device color appearance has changed (light/dark)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColors()
    }
    
    private func setColors() {
        [self.loginButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        [self.loginButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
    }
    
    @IBAction func closeButtonDidClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func profileImageButtonDidClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.isSingUp ? self.singUp() : self.login()
    }
    
    private func login() {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        AuthenticationService.signIn(email: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard authResult?.user != nil else {
                return
            }
            
            self.userLoggedIn()
        }
    }
    
    private func singUp() {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.repeatPasswordTextField.text ?? ""
        let name = self.nameTextField.text ?? ""
        let surname = self.surnameTextField.text ?? ""
        let nickname = self.nicknameTextField.text ?? ""
        var profileImage = self.profileImageView.image
        
        if profileImage == nil {
            profileImage = UIImage(systemName: "person.circle.fill")
        }
        
        guard let profileImageData = profileImage?.jpegData(compressionQuality: 0.5) else {
            let alert = self.createAlert(title: "Neuspesno kreiranje naloga", message: "Neuspesna kompresija profilne slike")
            self.present(alert, animated: false)
            return
        }
        
        guard self.checkSignUpForm(email: email, password: password, confirmPassword: confirmPassword) else {
            return
        }
        
        AuthenticationService.singUp(email: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard authResult?.user != nil else {
                return
            }
            
            let storageProfileRef = self.storageRef.child("profile").child(authResult?.user.uid ?? "")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            var profilePictureUrl = ""

            storageProfileRef.putData(profileImageData, metadata: metadata, completion: { (storageMetadata, error) in
                if let error = error {
                    print(error)
                    // Adding new user to 'users' Firestore collection without profile picture url string
                    Datafeed.shared.userRepository.addUser(authResult?.user.uid ?? "", profilePictureUrl, name, surname, nickname)
                    return
                }
                
                // Downloading profile picture url
                storageProfileRef.downloadURL(completion: { (url, error) in
                    if let metadataUrl = url?.absoluteString {
                        profilePictureUrl = metadataUrl
                        
                        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                            changeRequest.photoURL = URL(string: metadataUrl)
                            changeRequest.commitChanges(completion: { error in
                                self.delegate?.userPhotoUrlSuccesfullySaved(self)
                            })
                        }
                    }
                    
                    self.userLoggedIn()
                    // Adding new user to 'users' Firestore collection
                    Datafeed.shared.userRepository.addUser(authResult?.user.uid ?? "", profilePictureUrl, name, surname, nickname)
                })
            })
        }
    }
    
    private func userLoggedIn() {
        self.delegate?.userLoggedInSuccesfully(self)
        if let currentUser = Auth.auth().currentUser {
            Datafeed.shared.userRepository.getCurrentUser(uuid: currentUser.uid)
        }
    }
    
    private func checkSignUpForm(email: String, password: String, confirmPassword: String) -> Bool {
        guard self.isValidEmail(email) else {
            let alert = self.createAlert(title: "Neuspesno kreiranje naloga", message: "Neispravan format e-mail adrese")
            self.present(alert, animated: false)
            return false
        }
        
        guard self.isPasswordValid(password) else {
            let alert = self.createAlert(title: "Neuspesno kreiranje naloga", message: "Neispravna duzina lozinke")
            self.present(alert, animated: false)
            return false
        }
        
        guard password == confirmPassword else {
            let alert = self.createAlert(title: "Neuspesno kreiranje naloga", message: "Loznike se ne poklapaju")
            self.present(alert, animated: false)
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //TODO: Change password rules in the future
    private func isPasswordValid(_ password: String) -> Bool {
        return !(password.count < 8 || password.count > 15)
    }
    
    private func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        return alert
    }
}

//MARK: - UIImagePickerControllerDelegate
extension AccountViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.profileImageView.image = info[.originalImage] as? UIImage
        self.profileImageView.backgroundColor = .clear
        self.profileImageView.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}

extension AccountViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}
