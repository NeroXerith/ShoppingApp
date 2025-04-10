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
    
}



