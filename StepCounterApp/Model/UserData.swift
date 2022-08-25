//
//  UserDataModel.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 26.11.2020.
//
//
//import Foundation
//import Firebase
//
//struct UserData {
//    var expiration_date: String
//    var gift: String
//    var id: Int
//    var is_active: Bool
//    var name: String
//    var user_count: Int
//    var winner: String
//    var dictionary: [String: Any] {
//      return [
//        "expiration_date": expiration_date,
//        "gift": gift,
//        "id": id,
//        "is_active": is_active,
//        "name": name,
//        "user_count": user_count,
//        "winner": winner,
//      ]
//    }
//}
//
//extension UserData {
//  init?(dictionary: [String : Any]) {
//    guard let expiration_date = dictionary["expiration_date"] as? String,
//        let gift = dictionary["gift"] as? String,
//        let id = dictionary["id"] as? Int,
//        let is_active = dictionary["is_active"] as? Bool,
//        let name = dictionary["name"] as? String,
//        let user_count = dictionary["user_count"] as? Int,
//        let winner = dictionary["winner"] as? String
//
//        else { return nil }
//
//    self.init(expiration_date: expiration_date, gift: gift, id: id, is_active: is_active, name: name, user_count: user_count, winner: winner)
//  }
//}

class UserData{
    var nickname : String = ""
    var onesignal_player_id : String = ""
    var step_count : Int = 0
    var total_point : Int = 0
    var competitions : [String:Competition] = [String:Competition]()
}

class Competition{
    var end_date : String = ""
    var gift : String = ""
    var id: Int = 0
    var name: String = ""
//    var users : [String:Int] = [:]

    init() {
    }

    init(with dictionary: [String: Any]) {
        self.end_date = dictionary["end_date"] as! String
        self.gift = dictionary["gift"] as! String
        self.id = dictionary["id"] as! Int
        self.name = dictionary["name"] as! String
//        self.users = dictionary["users"] as! [String:Int]
    }
}
