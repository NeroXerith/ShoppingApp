//
//  FilterViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/7/25.
//

// FilterViewModel.swift
import Foundation
import Combine

class FilterViewModel: ObservableObject {
    @Published var sortOption: SortOption = .ascending
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100000
}

enum SortOption: String {
    case ascending = "asc"
    case descending = "desc"
}

