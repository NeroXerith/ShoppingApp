import UIKit
import Kingfisher
import Combine

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var productCollection: UICollectionView!
    
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
        productCollection.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionCell")

        productCollection.dataSource = self
        productCollection.delegate = self
        navigationItem.searchController = viewModel.searchBarController.searchController
       
        
        progressViewHandler = ProgressViewHandler(on: productCollection, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = productCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 10
            let availableWidth = productCollection.bounds.width
            let minColumnWidth: CGFloat = 160
            
            let maxNumColumns = floor((availableWidth + spacing) / (minColumnWidth + spacing))
            let numberOfColumns = max(1, maxNumColumns)
            
            let totalSpacing = (numberOfColumns - 1) * spacing + layout.sectionInset.left + layout.sectionInset.right
            let itemWidth = (availableWidth - totalSpacing) / numberOfColumns
            
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        }
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.productCollection.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    
    // MARK: - Subscribers
    private func observeViewModel() {
        viewModel.$unfilteredProductLists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.productCollection.reloadData() }
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
        
        viewModel.$filteredProductLists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.productCollection.reloadData() }
            .store(in: &cancellables)
    }
    
    @objc func refresh() {
        print("Pulled to refresh!")
        viewModel.refreshProducts()
    }
    
    
    // MARK: - Populate the tableView, Delegates and DataSource
    // Determine the rows of the table view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredProductLists.count
    }
    
    // Configure the UI for a specific cell and populate it
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollection.dequeueReusableCell(withReuseIdentifier: "ProductCollectionCell", for: indexPath) as! HomeCollectionViewCell
        
        let product = viewModel.filteredProductLists[indexPath.row]
        
        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        ProductImageManager.loadImage(into: cell.prodImageView, from: product.image)
        cell.prodCategory.text = product.category
        
        return cell
    }
    
    // Navigates to the product details screen when a row/cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = viewModel.filteredProductLists[indexPath.row]
        
        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let productDetailsViewModel = ProductDetailsViewModel(product: selectedProduct)
            productDetailsVC.viewModel = productDetailsViewModel
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "DiscoverSection",
                    for: indexPath
                ) as! SectionHeaderCollectionReusableView
            
                return header
            }
        return UICollectionReusableView()
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
