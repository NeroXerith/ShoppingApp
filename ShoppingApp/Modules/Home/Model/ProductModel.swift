//
//  ProductModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import Foundation

struct ProductDetails: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}
