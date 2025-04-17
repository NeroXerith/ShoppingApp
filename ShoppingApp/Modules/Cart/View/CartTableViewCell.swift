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
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var prodQtyLabel: UILabel!
    
    var updateQuantityHandler: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func increaseItemQuantity(_ sender: Any) {
        updateQuantityHandler?(true)
    }
    
    @IBAction func decreaseItemQuantity(_ sender: Any) {
        updateQuantityHandler?(false)
    }
    
}
