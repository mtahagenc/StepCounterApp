//
//  NProfileViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 2.03.2021.
//

import UIKit
import FirebaseAuth
import CoreMotion
import FirebaseDatabase
import Firebase

class NProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Constants and Variables
    let pedometer = CMPedometer()
    let userDefault = UserDefaults.standard
    let ref = Database.database().reference()
    let currentUser = Auth.auth().currentUser
    let activityIndicator = UIActivityIndicatorView()
    var imagePicker = UIImagePickerController()
    let imageRef = Storage.storage().reference().child(Auth.auth().currentUser!.uid)
    
    //MARK: - IBOutlets
    @IBOutlet weak var ppImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var totalStepsLbl: UILabel!
    @IBOutlet weak var totalPointsLbl: UILabel!
    @IBOutlet weak var nameSurname: UITextField!
    @IBOutlet weak var birthDate: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var changeImageBtnOutlet: UIButton!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        isTextsEmpty()
        getUserData()
        downloadImage()
        ppImageView.layer.cornerRadius = ppImageView.frame.height/2
        ppImageView.layer.borderWidth = 3
        ppImageView.layer.borderColor = UIColor.systemBlue.cgColor
        nameSurname.delegate = self
        birthDate.delegate = self
        phoneNumber.delegate = self
        imagePicker.delegate = self
        
        // These methods are added to move the view up to the keyboard size.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - IBAction Functions
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pastCompBtn(_ sender: UIButton) {
        print("Past Competitions")
    }
    @IBAction func changeImageBtn(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .savedPhotosAlbum

            present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func exitBtn(_ sender: UIButton) {
        logout()
        pedometer.stopEventUpdates()
    }
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        ref.child("users").child(currentUser!.displayName!).child("name").setValue(nameSurname.text)
        ref.child("users").child(currentUser!.displayName!).child("birthDate").setValue(birthDate.text)
        ref.child("users").child(currentUser!.displayName!).child("phoneNumber").setValue(phoneNumber.text)
        present(alertFunction(message: "Profil bilgileri güncellendi"), animated: true, completion: nil)
        getUserData()
    }
    
    //MARK: - Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        //These methods are added to move the view up to the keyboard size.
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        //These methods are added to move the view up to the keyboard size.
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    func logout() {
        do {
            try Auth.auth().signOut()
            userDefault.setValue(false, forKey: "userSignedIn")
            self.navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("already logged out")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameSurname {
            birthDate.becomeFirstResponder()
        } else if textField == birthDate {
            phoneNumber.becomeFirstResponder()
        } else if textField == phoneNumber {
            view.endEditing(true)
        }
        return true
    }
    func isTextsEmpty(){
        if nameSurname.text == "" {
            nameSurname.placeHolderColor = .red
        }
        if birthDate.text == "" {
            birthDate.placeHolderColor = .red
        }
        if phoneNumber.text == ""{
            phoneNumber.placeHolderColor = .red
        }
    }
    func getUserData() {
        ref.child("users").child(currentUser!.displayName!).observe(.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : Any] {
            
                //change activeComp with the snapshotValue
                self.nameSurname.text = snapshotValue["name"] as? String
                self.birthDate.text = snapshotValue["birthDate"] as? String
                self.phoneNumber.text = snapshotValue["phoneNumber"] as? String
                self.nameLbl.text = snapshotValue["nickname"] as? String
            } else {
                print("There is no user data")
            }
        }
    }
    func alertFunction(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Uyarı!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
        return alert
    }
    
    //MARK: - Picking, Uploading, and Downloading Image Methods
    func downloadImage () {
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("An error occured while downloading the image: \(error)")
            } else {
                let downloadedImage = UIImage(data: data!)
                self.ppImageView.image = downloadedImage
            }
        }
    }
    func uploadData (image: UIImage) {
        // Convert image to data and upload it to the reference
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    self.present(self.alertFunction(message: "Fotoğraf yüklenirken bir sorunla karşılaşıldı."), animated: true)
                } else {
                    // Create file metadata to update
                    let newMetadata = StorageMetadata()
                    newMetadata.contentType = "image/jpeg"
                    // Update metadata properties
                    self.imageRef.updateMetadata(newMetadata) { metadata, error in
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print(error)
                            self.present(self.alertFunction(message: "Fotoğraf yüklenirken bir sorunla karşılaşıldı."), animated: true)
                        } else {
                            // Updated metadata for '.jpg' is returned
                            print("success")
                        }
                    }
                }
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //We are picking the edited image
            ppImageView.image = pickedImage
            //After picking, we are uploading the image to the database
            uploadData(image: pickedImage)
        }
        else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //We are picking the original image
            ppImageView.image = pickedImage
            //After picking, we are uploading the image to the database
            uploadData(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //We are canceling the pickerView
        dismiss(animated: true, completion:nil)
    }
}
