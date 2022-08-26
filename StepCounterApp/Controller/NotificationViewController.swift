//
//  NavigationViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 10.09.2021.
//

import UIKit
import FirebaseAuth

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let isVerified = Auth.auth().currentUser?.isEmailVerified
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell

        cell.backgroundColor = .lightGray
        cell.notificationTxtView.backgroundColor = .lightGray
        
        if isVerified == true {
            print("varified")
        } else {
            cell.notificationTxtView.text = "Lütfen mail adresinizi doğrulayın. Eğer doğruladıysanız lütfen çıkış yapıp tekrar giriş yapın."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.height / 5
        return height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
    }
}
