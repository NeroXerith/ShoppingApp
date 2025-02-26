//
//  FetchProductDetails.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//
import Foundation

enum FetchError: Error {
    case networkError(String)
    case parsingError(String)
    case unknownError
}

class FetchProducts {
    private let fakeStoreAPI = FakeStoreAPI()
    
    func fetchProducts(completion: @escaping (Result<[ProductDetails], FetchError>) -> Void) {
        fakeStoreAPI.fetchData { result in
            switch result {
            case .success(let products):
                completion(.success(products))
            case .failure(let error):
                completion(.failure(.networkError(error.localizedDescription)))
            }
        }
    }
}

