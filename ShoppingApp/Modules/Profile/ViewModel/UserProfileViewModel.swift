//
//  UserProfileViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import Foundation
import Combine
import CoreData

final class UserProfileViewModel: ObservableObject {
    @Published var totalFavoritesCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTotalFavoritesCount()
    }
    
    func fetchTotalFavoritesCount() {
           totalFavoritesCount = CoreDataManager.shared.getTotalFavoritesCount()
       }
}
