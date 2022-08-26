//
//  ProductTableViewCell.swift
//  StepCounterApp
//
//  Created by Muhammet Taha Genç on 7.03.2021.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var productTitle: UILabel!
    
    
    @IBOutlet weak var productDescription: UILabel!
    
    
    @IBOutlet weak var productPrice: UILabel!
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
