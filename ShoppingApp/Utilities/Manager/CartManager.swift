//
//  CartManager.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/2/25.
//

import Foundation
import Combine
import CoreData
import UIKit
class CartManager {
    static let shared = CartManager()
    
    
    @Published private(set) var cartItems: [CartModel] = []
    private var cancellables = Set<AnyCancellable>()
    private var persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        loadCartFromStorage()
    }

    func addToCart(_ product: ProductDetails) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id}){
            cartItems[index].quantity += 1
            updateItemQuantity(productID: product.id, quantity: cartItems[index].quantity)
        } else {
            let newCartItem = CartModel(product: product, quantity: 1)
            cartItems.append(newCartItem)
            saveCartToStorage(newCartItem)
            print("Added Item \(product.title) to cart.")
        }
    }

    func removeFromCart(_ productID: Int) {
        cartItems.removeAll { $0.product.id == productID }
        deleteCartItemFromCoreData(productID)
    }
    
    func increaseQuantity(_ productID: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == productID }) {
            cartItems[index].quantity += 1
            updateItemQuantity(productID: productID, quantity: cartItems[index].quantity)
            print("Product ID \(productID) - Item quantity increase to \(cartItems[index].quantity)")
        }
    }
    
    func decreaseQuantity(_ productID: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == productID}) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
                updateItemQuantity(productID: productID, quantity: cartItems[index].quantity)
                print("Product ID \(productID) - Item quantity decrease to \(cartItems[index].quantity)")
            } else {
                print("Quantity cannot be reduce below 1")
            }
        }
    }
    
    func updateItemQuantity(productID: Int, quantity: Int) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemCartId == %d", productID)
        do {
            if let cartItem = try context.fetch(fetchRequest).first {
                cartItem.itemCartQty = Int64(quantity)
                saveContext(context: context)
            }

        } catch {
            print("Failed to update cart item : \(error)")
        }
    }
    
    private func saveCartToStorage(_ items: CartModel){
        let context = persistentContainer.viewContext
      
            let newCartItems = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart
            newCartItems.itemCartId = Int64(items.product.id)
            newCartItems.itemCartName = items.product.title
            newCartItems.itemCartDescription = items.product.description
            newCartItems.itemCartCategory = items.product.category
            newCartItems.itemCartPrice = items.product.price
            newCartItems.itemCartImageURL = items.product.image
            newCartItems.itemCartQty = Int64(items.quantity)
            newCartItems.itemCartRate = Double(items.product.rating.rate)
            newCartItems.itemCartCount = Int64(items.product.rating.count)
        
        saveContext(context: context)
    }
    
    private func loadCartFromStorage(){
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        do {
            let storedCartItems = try context.fetch(fetchRequest)
            
            cartItems = storedCartItems.map { item in
                CartModel(product: ProductDetails(
                    id: Int(item.itemCartId),
                    title: item.itemCartName ?? "",
                    price: item.itemCartPrice,
                    description: item.itemCartDescription ?? "",
                    category: item.itemCartCategory ?? "",
                    image: item.itemCartImageURL ?? "",
                    rating: Rating(rate: Double(item.itemCartRate), count: Int(item.itemCartCount))
                ), quantity: Int(item.itemCartQty))
            }
        } catch {
            print("Failed to load cart items : \(error)")
        }
    }
    
    func deleteCartItemFromCoreData(_ productID: Int){
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Cart> = Cart.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itemCartId == %d", productID)
        do {
            if let item = try context.fetch(fetchRequest).first {
                context.delete(item)
                saveContext(context: context)
            }
        } catch {
            print("Failed to update cart Item: \(error)")
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error saving context : \(error)")
        }
    }
}
