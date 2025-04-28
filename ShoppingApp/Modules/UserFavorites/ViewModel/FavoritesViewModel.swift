//
//  FavoritesViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        let userFavorites = CoreDataManager.shared.loadFavorites()
        self.favorites = userFavorites.map {
            FavoriteItem(id: $0.itemId, name: $0.itemName ?? "Unknown", image: $0.itemImage ?? "")
        }
    }
    
    func removeFavorite(favorite: FavoriteItem) {
        CoreDataManager.shared.removeFavorite(productId: Int(favorite.id))
        loadFavorites() // Reload the favorites after removal
    }
}
