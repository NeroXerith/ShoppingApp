//
//  HomeViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/26/25.
//

import Foundation
import Combine
    
class HomeViewModel: ObservableObject {
    @Published var productLists = [ProductDetails]()
        @Published var errorMessage: String?
        @Published var isLoading = false
        
        private var productFetcher = FetchProducts()
        var searchBarController = SearchBarController()
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            fetchProducts()
            setupSearchBarObserver()
        }
        
        func fetchProducts() {
            isLoading = true
            productFetcher.fetchProducts { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let products):
                        self?.searchBarController.setProducts(products)
                        self?.productLists = products
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
        
        private func setupSearchBarObserver() {
            searchBarController.$filteredProducts
                .sink { [weak self] results in
                    self?.productLists = results
                }
                .store(in: &cancellables)
        }
        
        func refreshProducts() {
            fetchProducts()
        }
    }

