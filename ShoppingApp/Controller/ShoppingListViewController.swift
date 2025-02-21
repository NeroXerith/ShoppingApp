import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    // Variables
    private let fetchProdImage = GetProductImage()
    var fakeStoreAPI = FakeStoreAPI()
    var productLists = [ProductDetails]() {
        didSet {
            tableProductList.reloadData()
            hideProgressView()
        }
    }

    var progressView: UIProgressView!
    var refreshControl = UIRefreshControl()
    

    @IBOutlet weak var tableProductList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProductList.dataSource = self
        tableProductList.delegate = self
        tableProductList.prefetchDataSource = self // Prefetching

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
            self?.fakeStoreAPI.fetchData { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let products):
                        self?.productLists = products
                        self?.progressView.setProgress(1.0, animated: true)
                    case .failure(let error):
                        print("Failed to fetch products: \(error.localizedDescription)")
                        self?.hideProgressView()
                    }
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
        
        fetchProdImage.fetchImage(from: product.image) { image in
            cell.prodImageView.image = image
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
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]){
        for indexPath in indexPaths {
            let products = productLists[indexPath.row]
            fetchProdImage.fetchImage(from: products.image, completion: { _ in })
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let urls: [String] = indexPaths.compactMap { indexPath in
            guard indexPath.row < productLists.count else { return nil }
            return productLists[indexPath.row].image
        }
        
        for url in urls {
            fetchProdImage.cancelImageFetch(from: url)
        }
    }
}
