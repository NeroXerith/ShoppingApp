//
//  ProductViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/19/25.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    // Segue
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var labelProdName: UILabel!
    @IBOutlet weak var labelProdDesc: UILabel!
    @IBOutlet weak var labelProdPrice: UILabel!
    @IBOutlet weak var labelProdCategory: UILabel!
    @IBOutlet weak var labelProdRating: UILabel!
    @IBOutlet weak var labelRatingCount: UILabel!
    
    @IBOutlet weak var averageStarView: AverageStarView!
    // Variables
    var selectedProduct: ProductDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let product = selectedProduct {
            labelProdName.text = product.title
            labelProdDesc.text = product.description
            labelProdPrice.text = "$\(String(product.price))"

                        if let imageUrl = URL(string: product.image) {
                            URLSession.shared.dataTask(with: imageUrl) { (data, _, _) in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.imageProduct.image = UIImage(data: data)
                                    }
                                }
                            }.resume()
                        }
            labelProdCategory.text = product.category
            labelProdRating.text = String(product.rating.rate)
            labelRatingCount.text = String(product.rating.count) + " ratings"
            averageStarView.updateStarRating(rating: product.rating.rate)
        }
        
        let labelProdNameHeight = labelProdName.optimalHeight
        let labelProdDescHeight = labelProdDesc.optimalHeight
        
        labelProdName.frame = CGRect(x: labelProdName.frame.origin.x, y: labelProdName.frame.origin.y, width: labelProdName.frame.width, height: labelProdNameHeight)
        labelProdName.numberOfLines = 0
        
        labelProdDesc.frame = CGRect(x: labelProdDesc.frame.origin.x, y: labelProdDesc.frame.origin.y, width: labelProdDesc.frame.width, height: labelProdDescHeight)
        labelProdDesc.numberOfLines = 0
        
    }
    


}
