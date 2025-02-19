import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Variables
    var fetchData = FakeStoreAPI()
    var productLists = [ProductDetails]() {
        didSet {
            DispatchQueue.main.async {
                self.tableProductList.reloadData()
                self.progressView.setProgress(1.0, animated: true)
                
                // Hide progress bar after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.progressView.isHidden = true
                }
            }
        }
    }

    var progressView: UIProgressView!
    var refreshControl = UIRefreshControl()
    var imageCache = NSCache<NSString, UIImage>()

    @IBOutlet weak var tableProductList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProductList.dataSource = self
        tableProductList.delegate = self

        setupProgressView()
        setupRefreshControl()
        fetchProducts()
    }


    func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .blue
        progressView.progress = 0.0
        progressView.isHidden = false // Show when starting

        navigationController?.navigationBar.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationController!.navigationBar.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

  
    func setupRefreshControl() {
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableProductList.refreshControl = refreshControl
    }

  
    func fetchProducts() {
        progressView.progress = 0.1
        progressView.isHidden = false
        
        fetchData.fetchData { [weak self] products in
            DispatchQueue.main.async {
                self?.productLists = products
                self?.progressView.setProgress(1.0, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.progressView.isHidden = true
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func refresh() {
        progressView.setProgress(0.1, animated: true) // Reset progress
        fetchProducts()
        print("Pulled to refresh!")
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

