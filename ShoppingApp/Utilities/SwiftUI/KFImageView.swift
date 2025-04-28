//
//  KFImageView.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import SwiftUI
import Kingfisher

struct KFImageView: View {
    let imageUrl: String
    
    var body: some View {
        KFImage(URL(string: imageUrl))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
}
