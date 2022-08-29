//
//  SettingsViewController.swift
//  StepCounterApp
//
//  Created by FeyzaGold on 28.08.2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SettingsViewController: UIViewController {

    var ref : DatabaseReference!
    var activeComp : ActiveComp = ActiveComp()
    var pastComp : [ActiveComp]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var giftTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBAction func sendBtn(_ sender: UIButton) {
        endTheComp()
        newComp()
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func endTheComp() {
        ref = Database.database().reference()
        ref.child("competitions").child("active").observe(.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : Any] {
            
                //change activeComp with the snapshotValue
                let gift = snapshotValue["gift"] as! String
                let id = snapshotValue["id"] as! String
                let name = snapshotValue["name"] as! String
                let users = snapshotValue["users"] as! [String : Int]
                let startDate = snapshotValue["start_date"] as! String
                let endDate = snapshotValue["end_date"] as! String
                
                print(self.activeComp)
                self.ref.child("competitions/past/\(id)/gift").setValue(gift)
                self.ref.child("competitions/past/\(id)/id").setValue(id)
                self.ref.child("competitions/past/\(id)/name").setValue(name)
                self.ref.child("competitions/past/\(id)/users").setValue(users)
                self.ref.child("competitions/past/\(id)/start_date").setValue(startDate)
                self.ref.child("competitions/past/\(id)/end_date").setValue(endDate)
            } else {
                print("There is no active competition.")
            }
        }
    }
    func newComp() {
        ref = Database.database().reference()
        
        ref.child("competitions/active/name").setValue(nameTextField.text)
        ref.child("competitions/active/gift").setValue(giftTextField.text)
        ref.child("competitions/active/id").setValue(idTextField.text)
        ref.child("competitions/active/start_date").setValue(startDateTextField.text)
        ref.child("competitions/active/end_date").setValue(endDateTextField.text)
        ref.child("competitions/active/users").setValue([Auth.auth().currentUser?.displayName:0])
    }
}
