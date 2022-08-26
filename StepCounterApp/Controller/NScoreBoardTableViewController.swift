//
//  MainViewController.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 27.12.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class NScoreBoardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Constants and Variables
    var ref : DatabaseReference!
    var userDatas : [[String: Any]] = []
    var sortedResults: [[String: Any]] = []
    var activityIndicator = UIActivityIndicatorView()
    
    //MARK: - IBOutlets
    @IBOutlet weak var nowBtnOutlet: UIButton!
    @IBOutlet weak var allTimeBtnOutlet: UIButton!
    @IBOutlet weak var scoreBoardTableView: UITableView!
    
    //MARK: - IBActions
    @IBAction func nowBtn(_ sender: UIButton) {
        nowBtnOutlet.setBackgroundImage(UIImage(named: "fill-rect"), for: .normal)
        nowBtnOutlet.setTitleColor(.white, for: .normal)
        allTimeBtnOutlet.setBackgroundImage(UIImage(named: "empty-rect"), for: .normal)
        allTimeBtnOutlet.setTitleColor(UIColor(red: 0.08, green: 0.33, blue: 0.72, alpha: 1.00), for: .normal)
        getCurrentRanking()
    }
    @IBAction func allTimeBtn(_ sender: UIButton) {
        nowBtnOutlet.setBackgroundImage(UIImage(named: "empty-rect"), for: .normal)
        nowBtnOutlet.setTitleColor(UIColor(red: 0.08, green: 0.33, blue: 0.72, alpha: 1.00), for: .normal)
        allTimeBtnOutlet.setBackgroundImage(UIImage(named: "fill-rect"), for: .normal)
        allTimeBtnOutlet.setTitleColor(.white, for: .normal)
        getAllTimeRanking()
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerTableViewCells()
        getCurrentRanking()
        setActivityIndicator()
    }
    
    //MARK: - TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "score", for: indexPath) as! ScoreTableViewCell
        
        //we are changing the first cell's background image to highlight it
        cell.backgroundImageView.image = indexPath.row == 0 ?  UIImage(named: "firstClass") : UIImage(named: "table-cell")
        
        cell.nicknameLabel.text = self.sortedResults[indexPath.row]["nickname"] as? String
        cell.scoreLabel.text = " \(indexPath.row + 1)"
        cell.stepLabel.text = String(self.sortedResults[indexPath.row]["step_count"] as! Int)
             
        return cell
    }
    
    //MARK: - Functions
    func getCurrentRanking() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        ref = Database.database().reference()
        ref.child("competitions").child("active").child("users").observe(.value) { (snapshot) in
            self.userDatas.removeAll()
            for child in snapshot.children{
                let data = child as! DataSnapshot
                let userDict = [
                    "nickname" : data.key,
                    "step_count" : data.value ?? 0
                ]
                self.userDatas.append(userDict)
            }
            DispatchQueue.main.async {
                self.sortedResults = (self.userDatas as NSArray).sortedArray(using: [NSSortDescriptor(key: "step_count", ascending: false)]) as! [[String:AnyObject]]
                self.scoreBoardTableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    func getAllTimeRanking() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        ref = Database.database().reference()
        ref.child("users").observe(.value) { (snapshot) in
            self.userDatas.removeAll()
            for child in snapshot.children{
                let data = child as! DataSnapshot
                let value = data.value! as! [String:Any]
                let userDict = [
                    "nickname" : value["nickname"],
                    "step_count" : value["step_count"]
                ]
                self.userDatas.append(userDict as [String : Any])
            }
            DispatchQueue.main.async {
                self.sortedResults = (self.userDatas as NSArray).sortedArray(using: [NSSortDescriptor(key: "step_count", ascending: false)]) as! [[String:AnyObject]]
                self.scoreBoardTableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    func setupTableView() {
        scoreBoardTableView.backgroundColor = .white
        scoreBoardTableView.delegate = self
        scoreBoardTableView.dataSource = self
        scoreBoardTableView.separatorStyle = .none
    }
    func registerTableViewCells () {
       //We are registering the cell we created to the tableview
       let scoreTableViewCell = UINib(nibName: "ScoreTableViewCell", bundle: nil)
       self.scoreBoardTableView.register(scoreTableViewCell, forCellReuseIdentifier: "score")
    }
    func setActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        self.view.addSubview(activityIndicator)
    }
}
