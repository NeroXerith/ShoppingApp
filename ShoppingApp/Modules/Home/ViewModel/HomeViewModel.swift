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
    @Published var unfilteredProductLists = [ProductDetails]()
    @Published var filteredProductLists: [ProductDetails] = []
    @Published var errorMessage: String?
    
    // MARK: - Filter Properties
    var filterViewModel = FilterViewModel()
    
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
                self?.unfilteredProductLists = products
                self?.filteredProductLists = products
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
                self?.filteredProductLists = results
            }
            .store(in: &cancellables)
    }
    
    // MARK: - [Subscriber] refresh the data when the user pull the screen
    func refreshProducts() {
        coreDataManager.loadProductsFromAPI()
    }
    
    func updateFilterOptions(
        titleSort: SortOption,
        priceSort: SortOption,
        minPrice: Double,
        maxPrice: Double,
        isPriceByChecked: Bool,
        isPriceRangeChecked: Bool
    ) {
        filterViewModel.titleSortOption = titleSort
        filterViewModel.priceSortOption = priceSort
        filterViewModel.minPrice = minPrice
        filterViewModel.maxPrice = maxPrice
        filterViewModel.isPriceByChecked = isPriceByChecked
        filterViewModel.isPriceRangeChecked = isPriceRangeChecked

        applyFilter()
    }

    func applyFilter() {
        var filtered = unfilteredProductLists

        // Step 1: Apply Title sort FIRST
        switch filterViewModel.titleSortOption {
        case .ascending:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            print("Applied title ascending")
        case .descending:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
            print("Applied title descending")
        default:
            break
        }

        // Step 2: Apply Price sort WITHIN titles
        if filterViewModel.isPriceByChecked {
            switch filterViewModel.priceSortOption {
            case .lowestToHighest:
                filtered.sort {
                    if $0.title == $1.title {
                        return $0.price < $1.price
                    } else {
                        return filterViewModel.titleSortOption == .ascending
                            ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                            : $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
                    }
                }
                print("Applied price: low to high within titles")
            case .highestToLowest:
                filtered.sort {
                    if $0.title == $1.title {
                        return $0.price > $1.price
                    } else {
                        return filterViewModel.titleSortOption == .ascending
                            ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                            : $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
                    }
                }
                print("Applied price: high to low within titles")
            default:
                break
            }
        }

        // Step 3: Apply Price Range Filter
        if filterViewModel.isPriceRangeChecked {
            filtered = filtered.filter {
                $0.price >= Double(filterViewModel.minPrice) &&
                $0.price <= Double(filterViewModel.maxPrice)
            }
        }

        self.filteredProductLists = filtered

        print("Title sort: \(filterViewModel.titleSortOption)")
        print("Price sort: \(filterViewModel.priceSortOption)")
        print("Price sort enabled: \(filterViewModel.isPriceByChecked)")
    }

}

