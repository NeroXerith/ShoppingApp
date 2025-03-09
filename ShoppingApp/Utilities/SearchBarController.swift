//
//  SearchBarController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/9/25.
//

import Foundation
import Combine
import UIKit

class SearchBarController: NSObject, UISearchBarDelegate {
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
    }
    
    func configSearchBar(for navigationItem: UINavigationItem) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search products..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        return searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.searchText = searchText
    }
}
