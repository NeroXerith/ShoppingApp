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

    @Published var isPriceByChecked: Bool = false
    @Published var isPriceRangeChecked: Bool = false

    private var cancellables = Set<AnyCancellable>()
}

enum SortOption {
    case ascending
    case descending
    case highestToLowest
    case lowestToHighest
}
