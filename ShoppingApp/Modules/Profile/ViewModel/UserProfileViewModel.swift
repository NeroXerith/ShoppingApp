//
//  UserProfileViewModel.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import Foundation
import Combine
import CoreData
import UIKit

final class UserProfileViewModel: ObservableObject {
    @Published var totalFavoritesCount: Int = 0
    
    @Published var avatarImage: UIImage? = nil
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var contactNumber: String = ""
    @Published var address: String = ""
    
    private var userData: UserProfileModel?
    
     private var cancellables = Set<AnyCancellable>()
     
     init() {
         fetchTotalFavoritesCount()
         loadUserData()
     }
     
     func fetchTotalFavoritesCount() {
         totalFavoritesCount = CoreDataManager.shared.getTotalFavoritesCount()
     }
     
    func loadUserData() {
        if let user = CoreDataManager.shared.fetchUser() {
            self.name = user.name ?? ""
            self.email = user.email ?? ""
            self.contactNumber = String(user.contactNumber)
            self.address = user.address ?? ""
            if let avatarData = user.avatarImg {
                self.avatarImage = UIImage(data: avatarData)
            }
        } else {
            // No user found, create default user
            CoreDataManager.shared.saveUserData(
                name: "Bryle Sanico",
                email: "astar8820@gmail.com",
                contactNumber: 09279709414,
                address: "266 E Vergel Pasay",
                avatarImage: UIImage(named: "default-avatar")
            )
            // Load the created user data
            loadUserData()
        }
    }
    
    func saveUserData() {
        guard let contactNumberInt = Int64(contactNumber) else {
                    print("Invalid contact number format.")
                    return
                }
                
                CoreDataManager.shared.updateUserData(
                    name: name,
                    email: email,
                    contactNumber: contactNumberInt,
                    address: address,
                    avatarImage: avatarImage
                )
        }
     
     func updateAvatarImage(_ image: UIImage) {
         avatarImage = image
         CoreDataManager.shared.updateUserAvatar(image: image)
     }
 }
