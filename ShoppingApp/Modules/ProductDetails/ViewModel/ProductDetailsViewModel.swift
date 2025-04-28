import Foundation
import Combine

class ProductDetailsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var product: ProductDetails?
    @Published var productImageURL: String?
    @Published var isLoading = false
    @Published var isFavorite: Bool = false
    
    private let coreDataManager = CoreDataManager.shared
    private var cartManager: CartManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(product: ProductDetails?, cartManager: CartManager = .shared) {
        self.product = product
        self.cartManager = cartManager
        self.productImageURL = product?.image
        self.loadFavoriteProducts()
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
    
    // MARK: - Favorite Product
    func loadFavoriteProducts() {
        isLoading = true
        guard let product = product else { return }
        productImageURL = product.image
        isFavorite = coreDataManager.isFavorite(productId: product.id)
        isLoading = false
    }
    
    func toggleFavorite() {
        guard let product = product else { return }
        if isFavorite {
            coreDataManager.removeFavorite(productId: product.id)
        } else {
            coreDataManager.saveFavorite(product: product)
        }
        isFavorite.toggle()
    }

}
