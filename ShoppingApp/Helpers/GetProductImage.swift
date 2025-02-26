//
//  GetProductImage.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/21/25.
//

import UIKit

class GetProductImage {
    
    private let imageCache = NSCache<NSString, UIImage>()
    private var runningTasks: [String: URLSessionDataTask] = [:]
    
    // MARK: - Image Place Holder
    private let placeholderImage: UIImage = UIImage(systemName: "photo")!
    private let errorHandlerImage: UIImage = UIImage(systemName: "exclamationmark.triangle")!
    
    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        // If image is cached return it
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        cancelImageFetch(from: urlString)
        
        // Placeholder while image is onload
        completion(placeholderImage)
        
        // Download Image if not cached
        guard let url = URL(string: urlString) else {
            completion(errorHandlerImage)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data, let image = UIImage(data: data), error == nil {
                self?.imageCache.setObject(image, forKey: urlString as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(self?.errorHandlerImage)
                }
            }
        
        }
        
        runningTasks[urlString] = dataTask
        dataTask.resume()
    }
    
    func cancelImageFetch(from urlString: String) {
        runningTasks[urlString]?.cancel()
        runningTasks.removeValue(forKey: urlString)
    }
}
