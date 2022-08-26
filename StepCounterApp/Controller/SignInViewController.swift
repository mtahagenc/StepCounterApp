//
//  SignInViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 25.11.2020.
//

import UIKit
import FirebaseAuth


class SignInViewController: UIViewController, UITextFieldDelegate {

    let userDefault = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: "userSignedIn")
    
    //creates activity indicator
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        self.view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userDefault.bool(forKey: "userSignedIn") == true {
            self.performSegue(withIdentifier: "showMain", sender: self)
        }
    }
    

    //MARK: - IBOutlets and IBActions
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBAction func signInBtn(_ sender: UIButton) {
        signIn(email: emailTxtField.text ?? "", password: passwordTxtField.text ?? "123123")
    }
    @IBAction func registerBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegister", sender: self)
    }
    @IBAction func forgotPasswordBtn(_ sender: UIButton) {
        if let email = emailTxtField.text{
            Auth.auth().languageCode = "tr"
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.present(self.alertFunction(message: "Bu mail adresiyle kayıtlı bir kullanıcı bulunmamaktadır.", title: "Şifre değiştirme isteği"), animated: true)
                    print(error)
                } else {
                    self.present(self.alertFunction(message: "Şifre değiştirme maili gönderilmiştir.", title: "Şifre değiştirme isteği"), animated: true)
                }
            }
        } else {
            self.present(alertFunction(message: "Lütfen mail alanına değiştirmek istediğiniz adresi yazınız", title: "Şifre değiştirme isteği"), animated: true)
        }
        
    }
    
            
    
    //MARK: - Functions
    func alertFunction(message: String ,title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
        
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        return alert
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTxtField {
            self.passwordTxtField.becomeFirstResponder()
        } else if textField == self.passwordTxtField {
            signIn(email: emailTxtField.text ?? "", password: passwordTxtField.text ?? "")
            view.endEditing(true)
        }
        return true
    }
    
    func signIn(email: String, password: String) {
        
        //shows and starts activity indicator and disable user interaction with view
        self.view.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    print("Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.")
                    self.present(self.alertFunction(message: "Beklenmeyen bir sorunla karşılaşıldı.", title: "Uyarı!"), animated: true)
                case .userDisabled:
                    print("Error: The user account has been disabled by an administrator.")
                    self.present(self.alertFunction(message: "Hesabınız yönetici tarafından askıya alındı. Lütfen bizimle iletişime geçin", title: "Uyarı!"), animated: true)
                case .wrongPassword:
                    print("Error: The password is invalid or the user does not have a password.")
                    self.present(self.alertFunction(message: "Geçersiz şifre!", title: "Uyarı!"), animated: true)
                case .invalidEmail:
                    print("Error: Indicates the email address is malformed.")
                    self.present(self.alertFunction(message: "Hatalı email formatı.", title: "Uyarı!"), animated: true)
                default:
                    print("Error: \(error.localizedDescription)")
                    self.present(self.alertFunction(message: "Beklenmeyen bir sorunla karşılaşıldı.", title: "Uyarı!"), animated: true)
                }
            } else {
                //hides and stops activity indicator and enable user interaction with view
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                //changes the userSignedIn boolean value for checking if user signedin or not
                self.userDefault.setValue(true, forKey: "userSignedIn")
                self.performSegue(withIdentifier: "showMain", sender: self)
            }
        }
    }
}
