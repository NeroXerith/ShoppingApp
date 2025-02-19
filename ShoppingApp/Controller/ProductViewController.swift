//
//  ProductViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/19/25.
//

import UIKit

class ProductViewController: UIViewController {
    // Segue
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var labelProdName: UILabel!
    @IBOutlet weak var labelProdDesc: UILabel!
    @IBOutlet weak var labelProdPrice: UILabel!
    
    // Variables
    var selectedProduct: ProductDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let product = selectedProduct {
            labelProdName.text = product.title
            labelProdDesc.text = product.description
            labelProdPrice.text = "$\(String(product.price))"
        }
        var labelProdDescHeight = labelProdDesc.optimalHeight
        labelProdDesc.frame = CGRect(x: labelProdDesc.frame.origin.x, y: labelProdDesc.frame.origin.y, width: labelProdDesc.frame.width, height: labelProdDescHeight)
        labelProdDesc.numberOfLines = 0
    }
    


}
