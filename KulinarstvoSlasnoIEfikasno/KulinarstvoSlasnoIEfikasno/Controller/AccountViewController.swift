//
//  AccountViewController.swift
//  KulinarstvoSlasnoIEfikasno
//
//  Created by Marko Veljkovic private on 25.4.23.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var isSingUp: Bool = false
    
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
        self.loginButton.setTitle("Ulogujte se", for: .normal)
        self.signUpButton.setTitle("Napravite nalog", for: .normal)
        
        [self.repeatPasswordLabel, self.repeatPasswordTextField, self.signUpButton].forEach {
            $0?.isHidden = !self.isSingUp
        }
        self.loginButton.isHidden = self.isSingUp
        
        [self.passwordTextField, self.repeatPasswordTextField].forEach {
            $0?.isSecureTextEntry = true
        }
        
        self.setColors()
    }
    
    // Device color appearance has changed (light/dark)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setColors()
    }
    
    private func setColors() {
        [self.loginButton, self.signUpButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = AppTheme.backgroundUniversalGreen.cgColor
        }
        
        [self.loginButton, self.signUpButton].forEach {
            $0?.backgroundColor = AppTheme.setBackgroundColor()
            $0?.setTitleColor(AppTheme.setTextColor(), for: .normal)
        }
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        AuthenticationService.signIn(email: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            
        }
    }
    
    @IBAction func singUpButtonClicked(_ sender: Any) {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.repeatPasswordTextField.text ?? ""
        
        guard self.checkSignUpForm(email: email, password: password, confirmPassword: confirmPassword) else {
            return
        }
        
        AuthenticationService.singUp(email: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            
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
        
        if password.count < 8 || password.count > 15 {
            return false
        }
        
        return true
    }
    
    private func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        return alert
    }
}
