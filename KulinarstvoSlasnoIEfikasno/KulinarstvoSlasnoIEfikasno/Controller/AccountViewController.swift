//
//  AccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 25.4.23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

enum AccountViewUsage : String {
    case Login, Signup, EditData, ChangePassword
}

protocol AccountViewControllerDelegate : AnyObject {
    func userLoggedInSuccesfully(_ controller: AccountViewController)
    func userPhotoUrlSuccesfullySaved(_ controller: AccountViewController)
    func userDataChanged(_ controller: AccountViewController)
    func userChangedPassword(_ controller: AccountViewController)
}

class AccountViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
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
    
    var viewType: AccountViewUsage = .Login
    let storageRef = Storage.storage().reference(forURL: "gs://culinary-dande.appspot.com")
    var isPictureChanged = false
    
    init(isLogin: Bool, isSignUp: Bool, isEditData: Bool, isChangePassword: Bool) {
        
        if isLogin {
            self.viewType = .Login
        }
        else if isSignUp {
            self.viewType = .Signup
        }
        else if isEditData {
            self.viewType = .EditData
        }
        else if isChangePassword {
            self.viewType = .ChangePassword
        }
        
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
        
        self.profileImageButton.setTitle("Izaberite profilnu sliku", for: .normal)
        self.forgotPasswordButton.setTitle("Zaboravljena lozinka", for: .normal)
        
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.black.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.tintColor = AppTheme.setTextColor()
        self.profileImageView.backgroundColor = AppTheme.setBackgroundColor()
        
        switch self.viewType {
        case .Login:
            self.setUpLoginView()
        case .Signup:
            self.setUpSignUpView()
        case .EditData:
            self.setUpEditAccountView()
        case .ChangePassword:
            self.setUpChangePasswordView()
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
    
    private func setUpLoginView() {
        self.loginButton.setTitle("Ulogujte se", for: .normal)
        self.profileImageView.isHidden = true
        
        [self.repeatPasswordLabel, self.repeatPasswordTextField, self.profileImageButton, self.nameLabel, self.nameTextField, self.surnameLabel, self.surnameTextField, self.nicknameLabel, self.nicknameTextField].forEach {
            $0?.isHidden = true
        }
    }
    
    private func setUpSignUpView() {
        self.loginButton.setTitle("Napravite nalog", for: .normal)
        [self.forgotPasswordButton].forEach {
            $0?.isHidden = true
        }
    }
    
    private func setUpEditAccountView() {
        self.loginButton.setTitle("Sačuvaj", for: .normal)
        
        [self.passwordLabel, self.passwordTextField, self.repeatPasswordLabel, self.repeatPasswordTextField, self.forgotPasswordButton].forEach {
            $0?.isHidden = true
        }
        
        self.emailTextField.text = Auth.auth().currentUser?.email ?? ""
        self.emailTextField.isEnabled = false
        self.emailTextField.textColor = .gray
        
        if let currentName = Datafeed.shared.currentUser?.name {
            self.nameTextField.text = currentName
        }
        
        if let currentSurname = Datafeed.shared.currentUser?.surname {
            self.surnameTextField.text = currentSurname
        }

        if let currentUsername = Datafeed.shared.currentUser?.nickname {
            self.nicknameTextField.text = currentUsername
        }
        
        self.getUserProfileImage()
    }
    
    private func setUpChangePasswordView() {
        self.loginButton.setTitle("Promeni lozinku", for: .normal)
        self.profileImageView.isHidden = true
        
        self.passwordLabel.text = "Nova lozinka"
        self.passwordTextField.placeholder = "Unesite novu lozinku"
        self.repeatPasswordLabel.text = "Potvrda nove lozinke"
        self.repeatPasswordTextField.placeholder = "Ponovo unesite novu lozinku"
        
        [self.emailLabel, self.emailTextField, self.profileImageButton, self.nameLabel, self.nameTextField, self.surnameLabel, self.surnameTextField, self.nicknameLabel, self.nicknameTextField, self.forgotPasswordButton].forEach {
            $0?.isHidden = true
        }
    }
    
    private func getUserProfileImage() {
        guard let imageUrl = Auth.auth().currentUser?.photoURL else {
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        if let imageFromCache = kImageCache.object(forKey: imageUrl as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.profileImageView.image = imageFromCache
            }
            return
        }
        
        let downloadTask = URLSession.shared.dataTask(with: imageUrl, completionHandler: { [weak self] (data, response, error) in
            guard let imageData = data, let profileImage = UIImage(data: imageData) else {
                return
            }
            
            kImageCache.setObject(profileImage, forKey: imageUrl as AnyObject)
            
            DispatchQueue.main.async {
                self?.profileImageView.image = profileImage
            }
        })
        
        downloadTask.resume()
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
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        //TODO: Change language code to app language when localization is added
//        Auth.auth().languageCode = "en"
        
        let alert = UIAlertController(title: "Unesite email adresu", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "E-mail adresa"
        }
        // OK action, email is sent
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let email = alert.textFields?[0].text ?? ""
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print(error)
                }
                else {
                    print("Link sent succesfully")
                }
            }
            
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Poništi", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func profileImageButtonDidClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        switch self.viewType {
        case .Login:
            self.login()
        case .Signup:
            self.singUp()
        case .EditData:
            self.saveChanges()
        case .ChangePassword:
            self.changePassword()
        }
    }
    
    private func saveChanges() {
        let name = self.nameTextField.text ?? ""
        let surname = self.surnameTextField.text ?? ""
        let nickname = self.nicknameTextField.text ?? ""
        
        Datafeed.shared.currentUser?.name = name
        Datafeed.shared.currentUser?.surname = surname
        Datafeed.shared.currentUser?.nickname = nickname
        
        if self.isPictureChanged {
            let profileImage = self.profileImageView.image
            
            guard let profileImageData = profileImage?.jpegData(compressionQuality: 0.5) else {
                let alert = self.createAlert(title: "Neuspesno kreiranje naloga", message: "Neuspesna kompresija profilne slike")
                self.present(alert, animated: false)
                return
            }
            
            guard Datafeed.shared.currentUser != nil else {
                return
            }
            
            let storageProfileRef = self.storageRef.child("profile").child(Datafeed.shared.currentUser?.uuid ?? "")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            var profilePictureUrl = ""

            storageProfileRef.putData(profileImageData, metadata: metadata, completion: { (storageMetadata, error) in
                if let error = error {
                    print(error)
                    Datafeed.shared.userRepository.updateUser(Datafeed.shared.currentUser ?? LocalUser(favoriteRecipes: [], uuid: "", name: "", surname: "", nickname: "", profilePictureUrl: ""))
                    self.closeViewAndOpenMyAccount()
                    return
                }
                
                // Downloading profile picture url
                storageProfileRef.downloadURL(completion: { (url, error) in
                    if let metadataUrl = url?.absoluteString {
                        profilePictureUrl = metadataUrl
                        Datafeed.shared.currentUser?.profilePictureUrl = profilePictureUrl
                        
                        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                            changeRequest.photoURL = URL(string: metadataUrl)
                            changeRequest.commitChanges(completion: { error in
                                self.delegate?.userPhotoUrlSuccesfullySaved(self)
                            })
                        }
                    }
                    Datafeed.shared.userRepository.updateUser(Datafeed.shared.currentUser ?? LocalUser(favoriteRecipes: [], uuid: "", name: "", surname: "", nickname: "", profilePictureUrl: ""))
                    self.closeViewAndOpenMyAccount()
                })
            })
        }
        else {
            Datafeed.shared.userRepository.updateUser(Datafeed.shared.currentUser ?? LocalUser(favoriteRecipes: [], uuid: "", name: "", surname: "", nickname: "", profilePictureUrl: ""))
            self.closeViewAndOpenMyAccount()
        }
        
    }
    
    private func closeViewAndOpenMyAccount() {
        self.dismiss(animated: true)
        self.delegate?.userDataChanged(self)
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
    
    private func changePassword() {
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.repeatPasswordTextField.text ?? ""
        
        guard self.checkChangePasswordForm(newPassword: password, confirmPassword: confirmPassword) else {
            return
        }
        
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if let error = error as? NSError {
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .userDisabled:
                    ()
                //User need to reented password for security reasons
                case .requiresRecentLogin:
                    let alert = UIAlertController(title: "Unesite staru lozniku", message: "", preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.placeholder = "Stara loznika"
                        textField.isSecureTextEntry = true
                    }
                    // OK action, reauthenticate is called
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        let password = alert.textFields?[0].text ?? ""
                        let credentials = EmailAuthProvider.credential(withEmail: Auth.auth().currentUser?.email ?? "", password: password)
                        
                        Auth.auth().currentUser?.reauthenticate(with: credentials) { [weak self] authRes, error in
                            if let error = error {
                                //TODO: process error
                                print(error)
                            }
                            // Call change password function again, user is reauthenticated
                            else {
                                self?.changePassword()
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Poništi", style: .cancel))
                    self.present(alert, animated: false)
                    break
                default:
                    print("Error message:  \(error.localizedDescription)")
                }
            }
            else {
                //Change password succesfully
                self.dismiss(animated: true)
                self.delegate?.userChangedPassword(self)
            }
            
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
    
    private func checkChangePasswordForm(newPassword: String, confirmPassword: String) -> Bool {
        
        guard self.isPasswordValid(newPassword) else {
            let alert = self.createAlert(title: "Neuspesna promena loznike", message: "Neispravna duzina nove lozinke")
            self.present(alert, animated: false)
            return false
        }
        
        guard newPassword == confirmPassword else {
            let alert = self.createAlert(title: "Neuspesna promena loznike", message: "Loznike se ne poklapaju")
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
        
        self.isPictureChanged = true
        
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
