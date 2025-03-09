//
//  FetchProductDetails.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//
import Foundation
import Alamofire

enum FetchError: Error {
    case networkError
    case parsingError
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .parsingError:
            return "Failed to parse data from the server."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

class FetchProducts {
    private let urlString = "https://fakestoreapi.com/products"
    
    func fetchProducts(completion: @escaping (Result<[ProductDetails], FetchError>) -> Void) {
        AF.request(urlString)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: [ProductDetails].self) { response in
                switch response.result {
                        case .success(let products):
                            completion(.success(products))
                        case .failure(_):
                            completion(.failure(.networkError))
            }
        }
    }
}

