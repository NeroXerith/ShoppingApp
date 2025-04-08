//
//  HomeCollectionViewCell.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/8/25.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var prodImageView: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    @IBOutlet weak var prodPriceLabel: UILabel!
    @IBOutlet weak var prodCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
