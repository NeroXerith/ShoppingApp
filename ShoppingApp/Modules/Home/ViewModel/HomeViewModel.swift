//
//  HomeViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/26/25.
//

import Foundation
import Combine
    
class HomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var productLists = [ProductDetails]()
    @Published var filteredProducts: [ProductDetails] = []
    @Published var errorMessage: String?
    @Published var titleSortOption: SortOption = .ascending
    @Published var priceSortOption: SortOption = .lowestToHighest
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100000
    @Published var isLoading: Bool = false
    
    // MARK: - Variables
    private var productFetcher = FetchProducts()
    private var coreDataManager = CoreDataManager.shared
    var searchBarController = SearchBarController()
    private var cancellables = Set<AnyCancellable>()
        
    init() {
        fetchProducts()
        setupSearchBarObserver()
    }
    
    // MARK: - [Subscriber] Retrieve data either from CoreData or Cloud
    func fetchProducts() {
        coreDataManager.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.productLists = products
                self?.filteredProducts = products
                self?.searchBarController.setProducts(products)
            }
            .store(in: &cancellables)
        
        coreDataManager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - [Subscriber]
    private func setupSearchBarObserver() {
        searchBarController.$filteredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.productLists = results
            }
            .store(in: &cancellables)
    }
    
    // MARK: - [Subscriber] refresh the data when the user pull the screen
    func refreshProducts() {
        coreDataManager.loadProductsFromAPI()
    }
    
    func applyFilter(titleSortOption: SortOption, priceSortOption: SortOption, minPrice: Double, maxPrice: Double) {
            var filtered = productLists.filter { $0.price >= minPrice && $0.price <= maxPrice }
            
            // Apply title sorting first
            switch titleSortOption {
            case .ascending:
                filtered.sort { $0.title < $1.title }
            case .descending:
                filtered.sort { $0.title > $1.title }
            default:
                break
            }

            // Apply price sorting after title sorting
            switch priceSortOption {
            case .lowestToHighest:
                filtered.sort { $0.price < $1.price }
            case .highestToLowest:
                filtered.sort { $0.price > $1.price }
            default:
                break
            }

            filteredProducts = filtered
        }
}

