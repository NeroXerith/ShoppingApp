import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Variables
    var fakeStoreAPI = FakeStoreAPI()
    var productLists = [ProductDetails]() {
        didSet {
            tableProductList.reloadData()
            hideProgressView()
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

    // MARK: - Progress View Setup
    func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .blue
        progressView.progress = 0.0

        navigationController?.navigationBar.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationController!.navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationController!.navigationBar.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    func showProgressView(with progress: Float = 0.1) {
        progressView.isHidden = false
        progressView.setProgress(progress, animated: true)
    }

    func hideProgressView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressView.isHidden = true
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - Refresh Control Setup
    func setupRefreshControl() {
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableProductList.refreshControl = refreshControl
    }

    @objc func refresh() {
        showProgressView(with: 0.1) // Reset progress
        fetchProducts()
        print("Pulled to refresh!")
    }
    
    // MARK: - Fetching Products Asynchronously
    func fetchProducts() {
        showProgressView()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fakeStoreAPI.fetchData { products in
                DispatchQueue.main.async {
                    self?.productLists = products
                    self?.progressView.setProgress(1.0, animated: true)
                }
            }
        }
    }

    // MARK: - TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableProductList.dequeueReusableCell(withIdentifier: "ProdListViewCell", for: indexPath) as! ProdListViewCell
        let product = productLists[indexPath.row]
        
        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        
        // Image Handling with Cache
        let imageUrlString = product.image
        if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
            cell.prodImageView.image = cachedImage
        } else if let imageUrl = URL(string: imageUrlString) {
            // Asynchronously load the image
            URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                if let data = data, let image = UIImage(data: data), error == nil {
                    DispatchQueue.main.async {
                        self?.imageCache.setObject(image, forKey: imageUrlString as NSString)
                        cell.prodImageView.image = image
                    }
                }
            }.resume()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = productLists[indexPath.row]
        
        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController {
            productDetailsVC.selectedProduct = selectedProduct
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
}
