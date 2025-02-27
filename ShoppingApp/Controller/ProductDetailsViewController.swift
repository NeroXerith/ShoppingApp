//
//  ProductViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/19/25.
//
import UIKit

class ProductDetailsViewController: UIViewController {
    
    // MARK: - Segue Outlets
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var labelProdName: UILabel!
    @IBOutlet weak var labelProdDesc: UILabel!
    @IBOutlet weak var labelProdPrice: UILabel!
    @IBOutlet weak var labelProdCategory: UILabel!
    @IBOutlet weak var labelProdRating: UILabel!
    @IBOutlet weak var labelRatingCount: UILabel!
    @IBOutlet weak var averageStarView: AverageStarView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    // MARK: - Variables
    var selectedProduct: ProductDetails?
    private let fetchProdImage = GetProductImage()
    private var progressViewHandler: ProgressViewHandler!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UILabel Programitacally
        labelRatingCount.layer.masksToBounds = true
        labelRatingCount.layer.cornerRadius = 5

        // Multiline Extension
        let labelProdNameHeight = labelProdName.optimalHeight
        let labelProdDescHeight = labelProdDesc.optimalHeight
                
                labelProdName.frame = CGRect(x: labelProdName.frame.origin.x, y: labelProdName.frame.origin.y, width: labelProdName.frame.width, height: labelProdNameHeight)
                labelProdName.numberOfLines = 0
                
                labelProdDesc.frame = CGRect(x: labelProdDesc.frame.origin.x, y: labelProdDesc.frame.origin.y, width: labelProdDesc.frame.width, height: labelProdDescHeight)
                labelProdDesc.numberOfLines = 0

        // Progress bar for api fetching completion
        progressViewHandler = ProgressViewHandler(on: scrollView, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))

        loadProductDetails()
    }
    
    // MARK: - Functions
    @objc func refresh() {
        progressViewHandler.showProgressView(with: 0.1)
        print("Pulled to Refresh!")
        loadProductDetails()
    }
    
    func loadProductDetails() {
        guard let product = selectedProduct else { return }
        
        labelProdName.text = product.title
        labelProdDesc.text = product.description
        labelProdPrice.text = "$\(String(product.price))"
        
        fetchProdImage.fetchImage(from: product.image) { image in
            self.imageProduct.image = image
        }
        
        labelProdCategory.text = product.category
        labelProdRating.text = String(product.rating.rate)
        labelRatingCount.text = " \(String(product.rating.count)) reviews \u{200c}"
        averageStarView.updateStarRating(rating: product.rating.rate)
        
        progressViewHandler.hideProgressView()
    }
}
