//
//  CartTableViewCell.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var prodImageHolder: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    @IBOutlet weak var prodCategoryLabel: UILabel!
    @IBOutlet weak var prodPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
