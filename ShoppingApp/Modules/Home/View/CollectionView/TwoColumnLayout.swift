//
//  TwoColumnLayout.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/10/25.
//

import UIKit

class TwoColumnLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let numberOfColumns: CGFloat = 2
        let spacing: CGFloat = minimumInteritemSpacing
        let sectionInsets = sectionInset
        
        let totalSpacing = (numberOfColumns - 1) * spacing + sectionInsets.left + sectionInsets.right
        
        let itemWidth = (collectionView.bounds.width - totalSpacing) / numberOfColumns
        
        itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        
    }
}
