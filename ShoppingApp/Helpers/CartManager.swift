//
//  CartModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/2/25.
//

import Foundation

class CartManager {
    static let shared = CartManager()
    
    private(set) var cartProducts: [CartModel] = []

    private init() {}

    func addToCart(_ product: ProductDetails) {
        if let index = cartProducts.firstIndex(where: { $0.product.id == product.id}){
            cartProducts[index].quantity += 1
        } else {
            let cartItem = CartModel(product: product, quantity: 1)
            cartProducts.append(cartItem)
            print("Added Item \(product.title) to cart.")
        }
    }

    func removeFromCart(_ productID: Int) {
        cartProducts.removeAll { $0.product.id == productID }
        print("Removed product with ID \(productID) from cart.")
    }
    
    func increaseQuantity(_ productID: Int) {
        if let index = cartProducts.firstIndex(where: { $0.product.id == productID }) {
            cartProducts[index].quantity += 1
            print("Product ID \(productID) - Item quantity increase to \(cartProducts[index].quantity)")
        }
    }
    
    func decreaseQuantity(_ productID: Int) {
        if let index = cartProducts.firstIndex(where: { $0.product.id == productID}) {
            if cartProducts[index].quantity > 1 {
                cartProducts[index].quantity -= 1
                print("Product ID \(productID) - Item quantity decrease to \(cartProducts[index].quantity)")
            } else {
                print("Quantity cannot be reduce below 1")
            }
        }
    }

    func getCartItems() -> [CartModel] {
        return cartProducts
    }
    
    func getItemQuantity(_ productID: Int) -> Int? {
        return cartProducts.first(where: { $0.product.id == productID})?.quantity ?? 0
    }
    
}
