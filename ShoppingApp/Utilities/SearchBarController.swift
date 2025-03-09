    //
    //  SearchBarController.swift
    //  ShoppingApp
    //
    //  Created by Biene Bryle Sanico on 3/9/25.
    //

    import Foundation
    import Combine
    import UIKit

    class SearchBarController: NSObject, UISearchResultsUpdating {
        
        // MARK: - Properties
        let searchController: UISearchController
        @Published private(set) var filteredProducts: [ProductDetails] = [] // Publisher
        
        private var allProducts: [ProductDetails] = []
        private var cancellables = Set<AnyCancellable>()
        
        // MARK: - Initialization
        override init() {
            searchController = UISearchController(searchResultsController: nil)
            super.init()
            
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.showsCancelButton = false
            searchController.searchBar.placeholder = "Search products..."
        }
        
        // Stores the Initial Product list
        func setProducts(_ products: [ProductDetails]) {
            self.allProducts = products // When search bar text is empty to return the initial list
            self.filteredProducts = products
        }
        
        // MARK: - Search Update Handling
        func updateSearchResults(for searchController: UISearchController) {
            guard let searchText = searchController.searchBar.text else {
                return
            }
            if searchText.isEmpty {
                filteredProducts = allProducts
            } else {
                filteredProducts = allProducts.filter {$0.title.localizedCaseInsensitiveContains(searchText)}
            }
        }
    }
