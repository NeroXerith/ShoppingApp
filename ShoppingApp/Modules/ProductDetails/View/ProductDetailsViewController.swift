import UIKit
import Combine

class ProductDetailsViewController: UIViewController {
    
    // MARK: - UI Outlets
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCategoryLabel: UILabel!
    @IBOutlet weak var productRatingLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var averageStarView: AverageStarView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    var viewModel: ProductDetailsViewModel! 
    private var progressViewHandler: ProgressViewHandler!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeViewModel()
        viewModel.loadProductDetails()
    }
    
    private func setupUI() {
        ratingCountLabel.layer.masksToBounds = true
        ratingCountLabel.layer.cornerRadius = 5
        productNameLabel.numberOfLines = 0
        productDescriptionLabel.numberOfLines = 0
        
        progressViewHandler = ProgressViewHandler(on: scrollView, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))
    }
    
    private func observeViewModel() {
        viewModel.$product
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                guard let self = self, let product = product else { return }
                self.updateUI(with: product)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.progressViewHandler.showProgressView() : self?.progressViewHandler.hideProgressView()
            }
            .store(in: &cancellables)
        
        viewModel.$productImageURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageURL in
                guard let self = self, let imageURL = imageURL else { return }
                ProductImageManager.loadImage(into: self.imageProduct, from: imageURL)
            }
            .store(in: &cancellables)
    }
    
    @objc private func refresh() {
        viewModel.isLoading = false
        viewModel.loadProductDetails()
    }
    
    private func updateUI(with product: ProductDetails) {
        productNameLabel.text = product.title
        productDescriptionLabel.text = product.description
        productPriceLabel.text = "$\(String(product.price))"
        productCategoryLabel.text = product.category
        productRatingLabel.text = String(product.rating.rate)
        ratingCountLabel.text = " \(String(product.rating.count)) reviews \u{200C}"
        averageStarView.updateStarRating(rating: product.rating.rate)
        progressViewHandler.hideProgressView()
    }
    
    @IBAction func productAddToCart(_ sender: Any) {
        viewModel.addToCart()
        
        let alert = UIAlertController(title: "Added to Cart",
                                      message: "\(viewModel.product?.title ?? "Product") has been added to your cart!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
