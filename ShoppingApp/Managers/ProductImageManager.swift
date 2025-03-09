//
//  ProductImageManager.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/6/25.
//

import Foundation
import Kingfisher

class ProductImageManager {
    // MARK: - Image Placeholder
    static let placeholderImage = UIImage(systemName: "photo")!
    static let errorImage =  UIImage(systemName: "exclamationmark.triangle")!
    
    // MARK: - Fetch Image using the Kingfisher
    static func loadImage(into imageView: UIImageView, from urlString: String){
        guard let url = URL(string: urlString) else {
            imageView.image = errorImage
            return
        }
        

        // setup the image properties using kingfisher
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage     
            ],
            completionHandler: { result in
                switch result {
                case .success(_):
                    break;
                case .failure(_):
                    imageView.image = errorImage
                }
            }
        )
    }
}
