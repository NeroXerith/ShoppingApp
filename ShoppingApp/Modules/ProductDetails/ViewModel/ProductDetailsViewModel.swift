import Foundation
import Combine

class ProductDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var product: ProductDetails?
    @Published var productImageURL: String?
    @Published var isLoading = false
    
    private var cartManager: CartManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(product: ProductDetails?, cartManager: CartManager = .shared) {
        self.product = product
        self.cartManager = cartManager
        self.productImageURL = product?.image
    }
    
    // MARK: - Load Product Details
    func loadProductDetails() {
        isLoading = true
        guard let product = product else { return }
        productImageURL = product.image
    }
    
    // MARK: - Add to Cart
    func addToCart() {
        guard let product = product else { return }
        cartManager.addToCart(product)
    }
}
