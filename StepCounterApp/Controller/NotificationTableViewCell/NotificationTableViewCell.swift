//
//  NotificationTableViewCell.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 11.09.2021.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var notificationTxtView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
