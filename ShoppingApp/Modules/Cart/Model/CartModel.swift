//
//  CartModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/3/25.
//
import Foundation

struct CartModel: Codable {
    let product: ProductDetails
    var quantity: Int
}
