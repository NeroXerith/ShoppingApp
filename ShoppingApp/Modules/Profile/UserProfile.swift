//
//  UserProfile.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/24/25.
//

import SwiftUI

struct UserProfile: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Spacer()
                    Image("default-avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 124, height: 124)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                        .accessibilityLabel("userProfile")
                        .accessibilityIdentifier(/*@START_MENU_TOKEN@*/"Identifier"/*@END_MENU_TOKEN@*/)
                    
                    Spacer().frame(height:20)
                    // Basic Information
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                        Group {
                            Text("Name:").bold()
                            Text("Bryle")
                            
                            Text("Contact #:").bold()
                            Text("09279709414")
                            
                            Text("Email:").bold()
                            Text("astar8820@gmail.com")
                            
                            Text("Address:").bold()
                            Text("266 E Vergel Pasay City ")
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Additional Information
                    Spacer().frame(height:20)
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                        Group {
                            Text("Name:").bold()
                            Text("Bryle")
                            
                            Text("Contact #:").bold()
                            Text("09279709414")
                            
                            Text("Email:").bold()
                            Text("astar8820@gmail.com")
                            
                            Text("Address:").bold()
                            Text("266 E Vergel Pasay City ")
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                .padding()
            }
        }
    }
}

#Preview {
    UserProfile()
}
