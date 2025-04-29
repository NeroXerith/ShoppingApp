//
//  UserProfile.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/24/25.
//

import SwiftUI

struct UserProfile: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showImagePicker = false
    @State private var isEditing = false 
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Profile Image
                    ZStack {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 134, height: 134)
                        
                        if let avatar = viewModel.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 124, height: 124)
                                .clipShape(Circle())
                        } else {
                            Image("default-avatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 124, height: 124)
                                .clipShape(Circle())
                        }
                    }
                    .shadow(radius: 5)
                    .padding(.top, 20)
                    .onTapGesture {
                        showImagePicker = true
                    }
                    
                    // Basic Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Basic Information")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            }) {
                                Image(systemName: isEditing ? "xmark.circle.fill" : "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                        }
                        
                        Divider()
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                            Group {
                                Text("Name:").bold()
                                if isEditing {
                                    TextField("Enter Name", text: $viewModel.name)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    Text(viewModel.name)
                                }
                                
                                Text("Contact #:").bold()
                                if isEditing {
                                    TextField("Enter Contact Number", text: $viewModel.contactNumber)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    Text(viewModel.contactNumber)
                                }
                                
                                Text("Email:").bold()
                                if isEditing {
                                    TextField("Enter Email", text: $viewModel.email)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    Text(viewModel.email)
                                }
                                
                                Text("Address:").bold()
                                if isEditing {
                                    TextField("Enter Address", text: $viewModel.address)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    Text(viewModel.address)
                                }
                            }
                        }
                        
                        if isEditing {
                            Button(action: {
                                viewModel.saveUserData()
                                withAnimation {
                                    isEditing = false
                                }
                            }) {
                                Text("Save Changes")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                    // Activities Section (your old code unchanged)
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activities")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Divider()
                        }
                        
                        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                            AdditionalInfoCard(
                                icon: "heart.fill",
                                title: "Favorites",
                                gradientColors: [Color.red, Color.pink],
                                badgeNumber: viewModel.totalFavoritesCount
                            ).onTapGesture {
                                openFavoritesScreen()
                            }
                            
                            AdditionalInfoCard(
                                icon: "cart.fill",
                                title: "Orders",
                                gradientColors: [Color.green, Color.green.opacity(0.7)],
                                badgeNumber: 0
                            )
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                viewModel.updateAvatarImage(image)
            }
        }
        .onAppear {
            viewModel.fetchTotalFavoritesCount()
        }
    }
    
    private func openFavoritesScreen() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            
            var navController: UINavigationController?

            if let nav = rootVC as? UINavigationController {
                navController = nav
            } else if let tab = rootVC as? UITabBarController {
                navController = tab.selectedViewController as? UINavigationController
            } else {
                navController = rootVC.navigationController
            }
            
            if let navController = navController {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let favoriteVC = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as? FavoritesViewController {
                    navController.pushViewController(favoriteVC, animated: true)
                }
            }
        }
    }
}

#Preview {
    UserProfile()
}
