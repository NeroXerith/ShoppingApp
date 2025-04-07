//
//  FilterViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/7/25.
//

import Foundation
import Combine

class FilterViewModel: ObservableObject {
    @Published var titleSortOption: SortOption = .ascending
    @Published var priceSortOption: SortOption = .lowestToHighest
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100000
}

enum SortOption: String {
    case ascending = "asc"
    case descending = "desc"
    case highestToLowest = "high_to_low"
    case lowestToHighest = "low_to_high"
}
