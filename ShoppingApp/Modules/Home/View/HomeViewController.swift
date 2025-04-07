import UIKit
import Kingfisher
import Combine

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var productTable: UITableView!
    
    // MARK: - Variables
    private var viewModel = HomeViewModel() // Bind the viewModel
    private var progressViewHandler: ProgressViewHandler!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeViewModel()
    }
    
    // MARK: - Config UI for this view
    private func setupUI() {
        productTable.dataSource = self
        productTable.delegate = self
        navigationItem.searchController = viewModel.searchBarController.searchController
        
        progressViewHandler = ProgressViewHandler(on: productTable, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))
    }
    
    // MARK: - Subscribers
    private func observeViewModel() {
        viewModel.$productLists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.productTable.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.progressViewHandler.showProgressView() : self?.progressViewHandler.hideProgressView()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { message in
                if let message = message {
                    print("Error: \(message)")
                }
            }
            .store(in: &cancellables)
        
        viewModel.$filteredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.productTable.reloadData() }
            .store(in: &cancellables)
    }
    
    @objc func refresh() {
        print("Pulled to refresh!")
        viewModel.refreshProducts()
    }
    
    
    // MARK: - Populate the tableView, Delegates and DataSource
    // Determine the rows of the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredProducts.count
    }
    
    // Configure the UI for a specific cell and populate it
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        let product = viewModel.filteredProducts[indexPath.row]
        
        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        ProductImageManager.loadImage(into: cell.prodImageView, from: product.image)
        cell.prodCategory.text = product.category
        
        return cell
    }
    
    // Navigates to the product details screen when a row/cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = viewModel.filteredProducts[indexPath.row]
        
        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let productDetailsViewModel = ProductDetailsViewModel(product: selectedProduct)
            productDetailsVC.viewModel = productDetailsViewModel
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }

    
    // MARK: - Functions for Button Actions
    // Function to Navigate to the Cart View
    @IBAction func gotoCartItemsAction(_ sender: Any) {
        if let shoppingCartVC = storyboard?.instantiateViewController(withIdentifier: "ShoppingCartViewController") as? ShoppingCartViewController {
            let ShoppingCartViewModel = ShoppingCartViewModel()
            shoppingCartVC.viewModel = ShoppingCartViewModel
            navigationController?.pushViewController(shoppingCartVC, animated: true)
        }
    }
    
    // Function to Navigate to the Advance Filtering sheet
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        let filterVC = FilterViewController(nibName: "FilterViewController", bundle: nil)
                
                if let sheet = filterVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 25
                }
                
        filterVC.applyFilter = { [weak self] titleSortOption, priceSortOption, minPrice, maxPrice in
            self?.viewModel.applyFilter(titleSortOption: titleSortOption, priceSortOption: priceSortOption, minPrice: minPrice, maxPrice: maxPrice)
        }
        
        present(filterVC, animated: true)
    }
}
