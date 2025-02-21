import Foundation

class FakeStoreAPI {
    func fetchData(completionHandler: @escaping (Result<[ProductDetails], Error>) -> Void) {
        let apiURL = "https://fakestoreapi.com/products"
        
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completionHandler(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("No response received from API")
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                return
            }
            
            print("Response statuse code: \(response.statusCode)" )
            
            do {
                let products = try JSONDecoder().decode([ProductDetails].self, from: data)
                completionHandler(.success(products))
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completionHandler(.failure(error))
            }
        }
        
        dataTask.resume()
    }
}
