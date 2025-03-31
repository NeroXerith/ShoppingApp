//
//  ShoppingCartViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/31/25.
//

import Combine
import UIKit
import Kingfisher

class ShoppingCartViewModel: ObservableObject {
    @Published private(set) var cartItems: [CartModel] = []
    @Published var total: String = "$0.00"

    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        CartManager.shared.$cartItems
            .sink { [weak self] items in
                self?.cartItems = items
                self?.updateTotalPrice()
            }
            .store(in: &cancellables)
    }
    
    func increaseQuantity(_ productID: Int) {
        CartManager.shared.increaseQuantity(productID)
    }
    
    func decreaseQuantity(_ productID: Int) {
        CartManager.shared.decreaseQuantity(productID)
    }
    
    func removeFromCart(_ productID: Int) {
        CartManager.shared.removeFromCart(productID)
    }
    
    private func updateTotalPrice() {
        let subTotal = cartItems.reduce(0) { result, item in
            result + (item.product.price * Double(item.quantity))
        }
        total = "$\(String(format: "%.2f", subTotal))"
    }
    
     func applyDiscount(voucherCode: String){
        
        let subTotal = cartItems.reduce(0) { result, item in
            result + (item.product.price * Double(item.quantity))
        }
       
        var discountedTotal: Double = subTotal
        
        if voucherCode == "STRAT50%OFF" {
            discountedTotal *= 0.5
        } else if voucherCode == "STRAT25%OFF" {
            discountedTotal *= 0.75
        }
        
        total = "$\(String(format: "%.2f", discountedTotal))"
    }
}
