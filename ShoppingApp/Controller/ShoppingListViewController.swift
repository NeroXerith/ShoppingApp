import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Variables
    var fetchData = FakeStoreAPI()
    var productLists = [ProductDetails]() {
        didSet {
            DispatchQueue.main.async {
                self.tableProductList.reloadData()
            }
        }
    }
    var imageCache = NSCache<NSString, UIImage>() // For Image Cache
    
    
    // Segue
    @IBOutlet weak var tableProductList: UITableView!
    
    
    // Screen OnLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProductList.dataSource = self
        tableProductList.delegate = self
        
        fetchData.fetchData { [weak self] products in
            self?.productLists = products
        }
        
        lazy var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableProductList.addSubview(refreshControl)
    }
    @objc func refresh(_ sender: Any?) {
        fetchData.fetchData { [weak self] products in
            self?.productLists = products
        }
        (sender as? UIRefreshControl)?.endRefreshing()
        print("Pulled!")
    }
    // TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableProductList.dequeueReusableCell(withIdentifier: "ProdListViewCell", for: indexPath) as! ProdListViewCell
        cell.prodNameLabel.text = productLists[indexPath.row].title
        cell.prodPriceLabel.text = "$\(String(productLists[indexPath.row].price))"
        
        let product = productLists[indexPath.row]
        let imageUrlString = product.image
                if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
                    // Use cached image
                    cell.prodImageView.image = cachedImage
                } else {
                    // Download image asynchronously
                    if let imageUrl = URL(string: imageUrlString) {
                        URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                            if let data = data, let image = UIImage(data: data), error == nil {
                                DispatchQueue.main.async {
                                    self?.imageCache.setObject(image, forKey: imageUrlString as NSString)
                                    cell.prodImageView.image = image
                                }
                            }
                        }.resume()
                    }
                }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = productLists[indexPath.row]
        
        // Instantiate
        if let productDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController {
            
            productDetailsVC.selectedProduct = selectedProduct
            
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
        
    }
}

