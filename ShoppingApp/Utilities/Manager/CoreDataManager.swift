//
//  CoreDataManager.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/1/25.
//

/*
 Implements CoreData for storage
 Use Combime for handling API Responses
 Fetches Products from CoreData first and updates after API call
 Ensures Offline availability of products
 */
import Foundation
import CoreData
import Combine
import UIKit
import Network

class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    private let fetchProductFromAPI = FetchProducts()
    
    @Published private(set) var products: [ProductDetails] = []
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private init() {
        persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        setupNetworkMonitoring()
    }
    
    // Check if device is connected to the internet or not
    func setupNetworkMonitoring() {
        NetworkManager.shared.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.loadProductsFromAPI()
                } else {
                    self?.loadProductsFromCoreData()
                }
            }
            .store(in: &cancellables)
    }
    
    // Retrieve data from API if not connected to the internet
    func loadProductsFromAPI() {
        isLoading = true
        fetchProductFromAPI.fetchProducts { [weak self] result in
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self?.products = products
                    self?.isLoading = false
                    self?.saveProductsToCoreData(products)
                }
            case .failure(let error):
                print("Error fetching products: \(error)")
                self?.isLoading = false
                
            }
        }
    }
    
    // Insert new Data to CoreData once connected to the internet
    func saveProductsToCoreData(_ products: [ProductDetails]){
        let context = self.persistentContainer.viewContext
        
        for product in products {
            let newProduct = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
            newProduct.id = Int64(product.id)
            newProduct.title = product.title
            newProduct.desc = product.description
            newProduct.category = product.category
            newProduct.price = product.price
            newProduct.imageURL = product.image
            newProduct.rate = Double(product.rating.rate)
            newProduct.count = Int64(product.rating.count)
        }
        
        do {
            // Clearing first to ensure no duplicates will be saved in the CoreData
            clearAllDataFromCoreData()
            // Saving to CoreData once clearing is complete
            try context.save()
        } catch {
            print("Failed to save Products: \(error)")
        }
        
    }
    
    func loadProductsFromCoreData(){
        isLoading = true
        let context = self.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            let storedProducts = try context.fetch(fetchRequest)
             products = storedProducts.map { product in
                ProductDetails(
                    id: Int(product.id),
                    title: product.title ?? "No title",
                    price: product.price,
                    description: product.desc ?? "No Description",
                    category: product.category ?? "No Category",
                    image: product.imageURL ?? "",
                    rating: Rating(rate: Double(product.rate), count: Int(product.count))
                )
                
            }
            isLoading = false
        } catch {
            print("Failed to fetch Products: \(error)")
            isLoading = false
        }
    }
    
    func clearAllDataFromCoreData() {
        let context = self.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Product.fetchRequest()
        let deleteRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to clear products: \(error)")
        }
    }
    
    // MARK: - Save Favorite Product
    func saveFavorite(product: ProductDetails) {
        let context = persistentContainer.viewContext
        
        let favorite = NSEntityDescription.insertNewObject(forEntityName: "UserFavorites", into: context)
        favorite.setValue(Int64(product.id), forKey: "itemId")
        favorite.setValue(product.image, forKey: "itemImage")
        favorite.setValue(product.title, forKey: "itemName")
        
        do {
            try context.save()
            print("Favorite saved successfully")
        } catch {
            print("Failed to save favorite: \(error)")
        }
    }
    
    func removeFavorite(productId: Int) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserFavorites")
        fetchRequest.predicate = NSPredicate(format: "itemId == %d", Int64(productId))
        
        do {
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject],
               let objectToDelete = results.first {
                context.delete(objectToDelete)
                try context.save()
                print("Favorite removed successfully")
            }
        } catch {
            print("Failed to remove favorite: \(error)")
        }
    }
    
    func isFavorite(productId: Int) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserFavorites> = UserFavorites.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemId == %d", Int64(productId))
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check favorite: \(error)")
            return false
        }
    }
    
    func loadFavorites() -> [UserFavorites] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserFavorites> = UserFavorites.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to load favorites: \(error)")
            return []
        }
    }
    
    func getTotalFavoritesCount() -> Int {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<UserFavorites> = UserFavorites.fetchRequest()
            
            do {
                let count = try context.count(for: fetchRequest)
                return count
            } catch {
                print("Failed to count favorites: \(error)")
                return 0
            }
        }
    
    
    // MARK: - Save Transaction
    func saveTransaction(cartItems: [Cart], totalAmount: Double) {
        let context = persistentContainer.viewContext
        
        // Create new Transaction
        let transaction = Transaction(context: context)
        transaction.transactionId = UUID().uuidString
        transaction.datePurchased = Date()
        transaction.totalAmount = totalAmount
        
        // Add each cart item to the transaction
        for cartItem in cartItems {
            let newItem = CartItem(context: context)
            newItem.itemId = cartItem.itemCartId
            newItem.itemName = cartItem.itemCartName
            newItem.itemDescription = cartItem.itemCartDescription
            newItem.itemCategory = cartItem.itemCartCategory
            newItem.itemImageURL = cartItem.itemCartImageURL
            newItem.itemPrice = cartItem.itemCartPrice
            newItem.quantity = cartItem.itemCartQty
            newItem.transaction = transaction 
        }
        
        do {
            try context.save()
            print("Transaction saved successfully!")
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    // MARK: - User Data
    func fetchUser() -> UserData? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func saveUserData(name: String, email: String, contactNumber: Int64, address: String, avatarImage: UIImage? = nil) {
        let context = persistentContainer.viewContext
        let userData = UserData(context: context)
        userData.name = name
        userData.email = email
        userData.contactNumber = contactNumber
        userData.address = address
        userData.avatarImg = avatarImage?.jpegData(compressionQuality: 0.8)

        do {
            try context.save()
            print("User Data saved successfully!")
        } catch {
            print("Failed to save user data: \(error)")
        }
    }

    func updateUserData(name: String, email: String, contactNumber: Int64, address: String, avatarImage: UIImage?) {
            let context = persistentContainer.viewContext
            if let user = fetchUser() {
                user.name = name
                user.email = email
                user.contactNumber = contactNumber
                user.address = address
                if let avatarImage = avatarImage {
                    user.avatarImg = avatarImage.jpegData(compressionQuality: 0.8)
                }
                
                do {
                    try context.save()
                } catch {
                    print("Failed to update user: \(error)")
                }
            }
        }
    
    func updateUserAvatar(image: UIImage) {
        let context = persistentContainer.viewContext
        guard let user = fetchUser() else { return }
        user.avatarImg = image.jpegData(compressionQuality: 0.8)
        if context.hasChanges{
            do {
                try context.save()
                print("User avatar saved successfully!")
            } catch {
                print("Failed to save user avatar: \(error)")
            }
        }
    }
}



