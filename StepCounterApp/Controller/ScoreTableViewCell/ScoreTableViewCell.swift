//
//  ScoreTableViewCell.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 27.12.2020.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

        
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
