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
    @Published var subTotal: Double = 0
    @Published var total: Double = 0
    @Published var isEmpty: Bool = false
    @Published var voucherCode: String = ""
    @Published var isVoucherValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        CartManager.shared.$cartItems
            .sink { [weak self] items in
                self?.cartItems = items
                self?.updateTotalPrice()
                self?.isEmpty = items.isEmpty
            }
            .store(in: &cancellables)
        
        $voucherCode
            .sink { [weak self] code in
                self?.applyDiscount(code: code)
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
        subTotal = cartItems.reduce(0) { result, item in
            result + (item.product.price * Double(item.quantity))
        }
        total = subTotal
        
        applyDiscount(code: voucherCode)
    }
    
    private func applyDiscount(code: String){
        
        var discountedTotal: Double = subTotal
       
        if voucherCode == "STRAT50%OFF" {
            discountedTotal *= 0.5
            isVoucherValid = true
        } else if voucherCode == "STRAT25%OFF" {
            discountedTotal *= 0.75
            isVoucherValid = true
        } else {
            isVoucherValid = false
        }
        
        total = discountedTotal
    }
}
