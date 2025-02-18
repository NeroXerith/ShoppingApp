//
//  ProdListViewCell.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import UIKit

class ProdListViewCell: UITableViewCell {
    
    @IBOutlet weak var prodImageView: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    @IBOutlet weak var prodPriceLabel: UILabel!
    
    static let identifier = "ProdListViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProdListViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
