//
//  Card.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/27/25.
//
import SwiftUI

// MARK: - Fancy Additional Info Card View
struct AdditionalInfoCard: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    let badgeNumber: Int
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        LinearGradient(colors: gradientColors, startPoint: .topTrailing, endPoint: .bottomLeading)
                    )
                    .frame(width: 95, height: 95)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                    .shadow(color: gradientColors.first?.opacity(0.6) ?? .black, radius: 10, x: 0, y: 5)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 35))
                            .foregroundStyle(.white)
                    )

                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("\(badgeNumber)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 10, y: -10)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}
