//
//  NMainViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 1.01.2021.
//

import UIKit
import CoreMotion
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class NMainViewController: UIViewController, MyDataSendingDelegateProtocol {
    
    //MARK: - Protocols
    func isPurchased(myData: String) {
        purchased = myData
    }
    
    //MARK: - Variables and Constants
    var purchased:String? = nil {
        didSet{
            IAPOutlet.setImage(UIImage(named: "thunder.fill"), for: .normal)
            //If boost purchased, the multiplier will be 2 and the number of steps will be doubled
            stepMultiplier = 2
        }
    }
    let pedometer = CMPedometer()
    let userDefault = UserDefaults.standard
    var stepMultiplier = 1
    var ref : DatabaseReference!
    var userData : UserData = UserData()
    var activeComp : ActiveComp = ActiveComp()
    let displayName = Auth.auth().currentUser!.displayName!
    var endDate: NSDate?
    var countdownTimer = Timer()

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        getActiveCompetition()
    }
    
    //MARK: - IBOutlets and IBActions
    @IBOutlet weak var currentStepCount: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var totalStepCountLabel: UILabel!
    
    @IBOutlet weak var IAPOutlet: UIButton!
    @IBAction func IAPButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showIAP", sender: self)
    }
    @IBAction func profileBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    @IBAction func notificationBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "showNotification", sender: self)
    }
    @IBAction func scoreTableBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "showScore", sender: self)
    }
    
    //MARK: - Timer Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIAP" {
            let secondVC: IAPViewController = segue.destination as! IAPViewController
            secondVC.delegate = self
        }
    }
    func startTimer(remainingTime : String) {

        let endDateString = remainingTime
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        endDate = endDateFormatter.date(from: endDateString)! as NSDate

        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    func stringToDate (dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:dateString)! + 3 * 60 * 60
        return date
    }
    @objc func updateTime() {

        let currentDate = Date()
        let calendar = Calendar.current

        let diffDateComponents = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: endDate! as Date)

        let countdown = "\(diffDateComponents.day ?? 0):\(diffDateComponents.hour ?? 0):\(diffDateComponents.minute ?? 0):\(diffDateComponents.second ?? 0)"

        currentStepCount.text = countdown
    }
    func startPedometer (ref: DatabaseReference, startDate: Date) {
        pedometer.startUpdates(from: startDate) { (data, error) in
            if error == nil {
                //rewrite the step data on the child
                self.ref.child("competitions/active/users/\(self.displayName)").setValue(data!.numberOfSteps.intValue*self.stepMultiplier)
            } else{
                print("An error was occured: \(error!)")
            }
        }
    }
    //MARK: - Firebase Functions
    func getActiveCompetition() {
        ref = Database.database().reference()
        getFirebaseData(ref: self.ref)
        ref.child("competitions").child("active").observe(.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : Any] {
            
                //change activeComp with the snapshotValue
                self.activeComp.gift = snapshotValue["gift"] as! String
                self.activeComp.id = snapshotValue["id"] as! Int
                self.activeComp.name = snapshotValue["name"] as! String
                self.activeComp.users = snapshotValue["users"] as! [String : Int]
                
                //turn date strings into dates
                let startDate = snapshotValue["start_date"] as! String
                self.activeComp.start_date = self.stringToDate(dateString: startDate)
                
                let endDate = snapshotValue["end_date"] as! String
                self.activeComp.end_date = self.stringToDate(dateString: endDate)
                
                //start pedometer with the starDate and current step data
                self.startPedometer(ref: self.ref, startDate: self.activeComp.start_date)
                
                //start timer to count down
                self.startTimer(remainingTime: endDate)
                
                //reload ui with the new activeComp data
                self.totalStepCountLabel.text = String(self.activeComp.users[self.displayName] ?? 0)
            } else {
                self.pedometer.stopUpdates()
                print("There is no active competition.")
            }
        }
    }
    func getFirebaseData(ref: DatabaseReference) {
        //gets the user data in the firebase
        ref.child("users").child(self.displayName).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:Any] {
                
                //change oneSignalPlayerID
                if let oneSignalPlayerId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
                    ref.child("users").child(self.displayName).child("onesignal_player_id").setValue(oneSignalPlayerId)
                } else {
                    print("There is no One Signal Player Id in the device")
                }
                //change userData with the snapshotValue
                self.userData.nickname = snapshotValue["nickname"] as! String
                self.userData.step_count = snapshotValue["step_count"] as! Int
                self.userData.total_point = snapshotValue["total_point"] as! Int
                self.userData.onesignal_player_id = snapshotValue["onesignal_player_id"] as! String
                
                let childSnap = snapshot.childSnapshot(forPath: "competitions")
                if let childSnapValue = childSnap.value as? [String:Any] {
                    childSnapValue.forEach { (element) in
                        self.userData.competitions.updateValue(Competition(with: element.value as! [String:Any]), forKey: element.key)
                    }
                    self.reloadUIWithFirebaseData(userData: self.userData)
                } else {
                    print("something wrong with the childSnap")
                }
            } else {
                print("An error occured while assigning snapshotValue to userData")
            }
        }
    }
    func reloadUIWithFirebaseData(userData:UserData) {
        totalPointsLabel.text = String(userData.total_point)
        totalStepCountLabel.text = String(userData.step_count)
    }
}

// We should use this function to show the total steps because it may turn to millions of steps after couple of months for the user.

//func formatNumber(_ i: Int) -> String {
//    let nf = NumberFormatter()
//    nf.usesGroupingSeparator = true
//    nf.numberStyle = .decimal
//
//    var newNum: Double = 0
//    var numDec: Int = 0
//    var sPost: String = ""
//
//    switch i {
//    case 0..<10_000:
//        newNum = Double(i)
//    case 10_000..<100_000:
//        newNum = Double(i) / 1_000.0
//        numDec = 1
//        sPost = "K"
//    case 100_000..<1_000_000:
//        newNum = Double(i) / 1_000.0
//        sPost = "K"
//    case 1_000_000..<100_000_000:
//        newNum = Double(i) / 1_000_000.0
//        numDec = 1
//        sPost = "M"
//    default:
//        newNum = Double(i) / 1_000_000.0
//        sPost = "M"
//    }
//
//    nf.maximumFractionDigits = numDec
//    return (nf.string(for: newNum) ?? "0") + sPost
//}
