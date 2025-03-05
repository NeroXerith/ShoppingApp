//
//  FetchProductDetails.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//
import Foundation
import Alamofire

enum FetchError: Error {
    case networkError(String)
    case parsingError(String)
    case unknownError
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
                        case .failure(let error):
                            completion(.failure(.networkError(error.localizedDescription)))
            }
        }
    }
}

