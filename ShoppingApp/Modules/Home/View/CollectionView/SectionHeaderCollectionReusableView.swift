//
//  SectionHeaderCollectionReusableView.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/21/25.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sectionIconImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        sectionIconImage.tintColor = .orange
    }

    func configure(with title: String) {
        titleLabel.text = title

        switch title.lowercased() {
        case "popular products":
            sectionIconImage.image = UIImage(systemName: "star.fill")
        case "discover":
            sectionIconImage.image = UIImage(systemName: "magnifyingglass")
        default:
            sectionIconImage.image = nil
        }
    }
}
