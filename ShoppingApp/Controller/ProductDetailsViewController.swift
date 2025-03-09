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
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var productRatingLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var averageStarView: AverageStarView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    // MARK: - Variables
    var selectedProduct: ProductDetails? // Global variable that holds the product details passed from Shopping list view
    private var progressViewHandler: ProgressViewHandler!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProductDetails()
    }
    
    // MARK: - Functions
    // Configure the UI for this view
    func setupUI(){
        // UILabel Programitacally
        ratingCountLabel.layer.masksToBounds = true
        ratingCountLabel.layer.cornerRadius = 5

        // Multiline Extension
        let labelProductNameHeight = productNameLabel.optimalHeight
        let labelProductDescriptionHeight = productDescriptionLabel.optimalHeight
                
                productNameLabel.frame = CGRect(x: productNameLabel.frame.origin.x, y: productNameLabel.frame.origin.y, width: productNameLabel.frame.width, height: labelProductNameHeight)
                productNameLabel.numberOfLines = 0
                
                productDescriptionLabel.frame = CGRect(x: productDescriptionLabel.frame.origin.x, y: productDescriptionLabel.frame.origin.y, width: productDescriptionLabel.frame.width, height: labelProductDescriptionHeight)
                productDescriptionLabel.numberOfLines = 0

        // Progress bar for api fetching completion
        progressViewHandler = ProgressViewHandler(on: scrollView, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))

    }
    
    // Refreshes the product lists when user pulls the screen to refresh
    @objc func refresh() {
        progressViewHandler.showProgressView(with: 0.1)
        print("Pulled to Refresh!")
        loadProductDetails()
    }
    
    // Function to display the details of the product that came from the previous view
    func loadProductDetails() {
        guard let product = selectedProduct else { return }

        productNameLabel.text = product.title
        productDescriptionLabel.text = product.description
        productPriceLabel.text = "$\(String(product.price))"
        
        ProductImageManager.loadImage(into: imageProduct, from: product.image)
        
        productCategoryLabel.text = product.category
        productRatingLabel.text = String(product.rating.rate)
        ratingCountLabel.text = " \(String(product.rating.count)) reviews \u{200c}"
        averageStarView.updateStarRating(rating: product.rating.rate)
        
        progressViewHandler.hideProgressView()
    }
    
    // MARK: - Functions for Button Actions
    @IBAction func prdouctAddToCart(_ sender: Any) {
        guard let product = selectedProduct else { return }
        
        CartManager.shared.addToCart(product)
        
        let alert = UIAlertController(title: "Added to Cart", message: "\(product.title) has been added to your cart!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                present(alert, animated: true)
        
    }
    
}
