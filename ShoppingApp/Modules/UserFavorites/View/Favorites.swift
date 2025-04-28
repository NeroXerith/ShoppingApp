//
//  Favorites.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import SwiftUI

struct Favorites: View {
    @ObservedObject var viewModel = FavoritesViewModel()
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.favorites) { favorite in
                        HStack(spacing: 16) {
                            KFImageView(imageUrl: favorite.image)
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(favorite.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.removeFavorite(favorite: favorite)
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .padding(10)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
}

#Preview {
    Favorites()
}
