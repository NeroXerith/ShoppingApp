//
//  ProductTableViewCell.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var prodImageView: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    @IBOutlet weak var prodPriceLabel: UILabel!
    @IBOutlet weak var prodCategory: UILabel!
    
    static let identifier = "ProductTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProductTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tableCellLabelProdHeight = prodNameLabel.optimalHeight
        prodNameLabel.frame = CGRect(x: prodNameLabel.frame.origin.x, y: prodNameLabel.frame.origin.y, width: prodNameLabel.frame.width, height: tableCellLabelProdHeight)
        prodNameLabel.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
 
