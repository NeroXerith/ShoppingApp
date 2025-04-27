//
//  UserProfile.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/24/25.
//
import SwiftUI

struct UserProfile: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
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

                        Image("default-avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 124, height: 124)
                            .clipShape(Circle())
                    }
                    .shadow(radius: 5)
                    .padding(.top, 20)
                    .accessibilityLabel("User Profile")
                    .accessibilityIdentifier("UserProfileImage")

                    
                    
                    // Basic Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Basic Information")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Divider()
                                .background(Color.secondary)
                        }
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                            Group {
                                Text("Name:").bold()
                                Text("Bryle")
                                
                                Text("Contact #:").bold()
                                Text("09279709414")
                                
                                Text("Email:").bold()
                                Text("astar8820@gmail.com")
                                
                                Text("Address:").bold()
                                Text("266 E Vergel Pasay City")
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                    // Additional Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activities")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                        }
                        
                        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                            AdditionalInfoCard(icon: "heart.fill", title: "Favourites", gradientColors: [Color.red, Color.pink], badgeNumber: 9)
                            
                            AdditionalInfoCard(icon: "cart.fill", title: "Your Orders", gradientColors: [Color.green, Color.green.opacity(0.7)], badgeNumber: 9)
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
    }
}


#Preview {
    UserProfile()
}
