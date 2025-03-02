//
//  CartModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/2/25.
//

import Foundation

class CartManager {
    static let shared = CartManager()
    
    private(set) var cartProducts: [ProductDetails] = []

    private init() {}

    func addToCart(_ product: ProductDetails) {
        guard !cartProducts.contains(where: { $0.id == product.id }) else {
            print("Product already in cart")
            return
        }
        cartProducts.append(product)
        print("Added \(product.title) to cart.")
    }

    func removeFromCart(_ productID: Int) {
        cartProducts.removeAll { $0.id == productID }
        print("Removed product with ID \(productID) from cart.")
    }

    func getCartItems() -> [ProductDetails] {
        return cartProducts
    }
}
