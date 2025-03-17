//
//  CartManager.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/2/25.
//

import Foundation
import Combine

class CartManager {
    static let shared = CartManager()
    
    @Published private(set) var cartItems: [CartModel] = []
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadCartFromStorage()
        
        $cartItems
            .sink { [weak self] items in
                self?.saveCartToStorage(items)
            }.store(in: &cancellables)
    }

    func addToCart(_ product: ProductDetails) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id}){
            cartItems[index].quantity += 1
        } else {
            let cartItem = CartModel(product: product, quantity: 1)
            cartItems.append(cartItem)
            print("Added Item \(product.title) to cart.")
        }
    }

    func removeFromCart(_ productID: Int) {
        cartItems.removeAll { $0.product.id == productID }
        print("Removed product with ID \(productID) from cart.")
    }
    
    func increaseQuantity(_ productID: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == productID }) {
            cartItems[index].quantity += 1
            print("Product ID \(productID) - Item quantity increase to \(cartItems[index].quantity)")
        }
    }
    
    func decreaseQuantity(_ productID: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == productID}) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
                print("Product ID \(productID) - Item quantity decrease to \(cartItems[index].quantity)")
            } else {
                print("Quantity cannot be reduce below 1")
            }
        }
    }

    func getCartItems() -> [CartModel] {
        return cartItems
    }
    
    func getItemQuantity(_ productID: Int) -> Int? {
        return cartItems.first(where: { $0.product.id == productID})?.quantity ?? 0
    }
    
    private func saveCartToStorage(_ items: [CartModel]){
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "cartItems")
        }
    }
    
    private func loadCartFromStorage(){
        if let savedData = UserDefaults.standard.data(forKey: "cartItems"),
           let decodedItems = try? JSONDecoder().decode([CartModel].self, from: savedData){
            cartItems = decodedItems
        }
    }
    
}
