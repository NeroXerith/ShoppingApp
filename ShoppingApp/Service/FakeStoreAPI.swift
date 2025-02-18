import Foundation

class FakeStoreAPI {
    func fetchData(completionHandler: @escaping ([ProductDetails]) -> Void) {
        let apiURL = "https://fakestoreapi.com/products"
        
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            completionHandler([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completionHandler([]) 
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                completionHandler([])
                return
            }
            
            do {
                let products = try JSONDecoder().decode([ProductDetails].self, from: data)
                completionHandler(products)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completionHandler([])
            }
        }
        
        task.resume()
    }
}
