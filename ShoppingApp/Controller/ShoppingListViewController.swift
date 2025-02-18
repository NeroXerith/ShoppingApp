import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource {
    var fetchData = FakeStoreAPI()
    var productLists = [ProductDetails]() {
        didSet {
            DispatchQueue.main.async {
                self.tableProductList.reloadData()
            }
        }
    }

    @IBOutlet weak var tableProductList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProductList.dataSource = self
        fetchData.fetchData { [weak self] products in
            self?.productLists = products
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableProductList.dequeueReusableCell(withIdentifier: "ProdListViewCell", for: indexPath) as! ProdListViewCell
        cell.prodNameLabel.text = productLists[indexPath.row].title
        // Load image from URL asynchronously
        let product = productLists[indexPath.row]
        if let imageUrl = URL(string: product.image) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.prodImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        cell.prodPriceLabel.text = String(productLists[indexPath.row].price)
        return cell
    }
}

