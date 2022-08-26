//
//  RegisterViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 25.11.2020.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var ref : DatabaseReference!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        self.view.addSubview(activityIndicator)
        self.hideKeyboardWhenTappedAround()
        
        userNameTxtField.delegate = self
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    
    //MARK: - IBOutlets and IBActions
    
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        self.view.isUserInteractionEnabled = false
        signUp(email: emailTxtField.text ?? "", password: passwordTxtField.text ?? "")
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userNameTxtField {
            self.emailTxtField.becomeFirstResponder()
        } else if textField == self.emailTxtField {
            self.passwordTxtField.becomeFirstResponder()
        } else if textField == self.passwordTxtField {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            self.view.isUserInteractionEnabled = false
            signUp(email: emailTxtField.text ?? "", password: passwordTxtField.text ?? "")
            view.endEditing(true)
        }
        return true
    }
    func alertFunction(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Uyarı!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        return alert
    }
    func signUp(email: String, password: String) {
        //gets the user data in the firebase
        Database.database().reference().child("users").observeSingleEvent(of: .value) { [self](snapshot) in
            if snapshot.hasChild(self.userNameTxtField.text!){
                self.present(alertFunction(message: "Seçmiş olduğunuz kullanıcı adı daha önceden alınmış."), animated: true)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                    if let error = error as NSError? {
                      switch AuthErrorCode(rawValue: error.code) {
                      case .operationNotAllowed:
                        print("Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
                        self.present(alertFunction(message: "Beklenmeyen bir sorunla karşılaşıldı."), animated: true)
                      case .emailAlreadyInUse:
                        print("Error: The email address is already in use by another account.")
                        self.present(alertFunction(message: "Yazdığınız mail adresi zaten kullanımda."), animated: true)
                      case .invalidEmail:
                        print("Error: The email address is badly formatted.")
                        self.present(alertFunction(message: "Mail adresinizin formatı kontrol ediniz."), animated: true)
                      case .weakPassword:
                        print("Error: The password must be 6 characters long or more.")
                        self.present(alertFunction(message: "Şifre en az altı karakterli olmalıdır."), animated: true)
                      default:
                        print("Error: \(error.localizedDescription)")
                        self.present(alertFunction(message: "Beklenmeyen bir sorunla karşılaşıldı."), animated: true)
                       }
                    } else {
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                        
                        self.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        //create database reference
                        self.ref = Database.database().reference()
                        //create new child and write a value on the existance child
                        if self.userNameTxtField.text == ""{
                            print("User Name can not be nill!")
                            self.present(self.alertFunction(message: "Kullanıcı adı boş bırakılamaz"), animated: true)
                        } else {
                            UserDefaults.standard.setValue(true, forKey: "userSignedIn")
                            if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
                                //we are changing the display name of the user
                                currentUser.displayName = self.userNameTxtField.text!
                                currentUser.commitChanges(completion: { error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        print("DisplayName changed")
                                        self.ref.child("users").child(currentUser.displayName!).setValue(["nickname": self.userNameTxtField.text ?? ""])
                                        self.ref.child("users/\(currentUser.displayName!)/step_count").setValue(Int(0))
                                        self.ref.child("users/\(currentUser.displayName!)/total_point").setValue(Int(0))
                                        self.ref.child("users/\(currentUser.displayName!)/onesignal_player_id").setValue("")

                                        self.performSegue(withIdentifier: "showMainFromRegister", sender: self)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
