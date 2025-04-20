import UIKit
import Kingfisher
import Combine


enum HomeSection: Int, CaseIterable {
    case popular
    case discover

    var title: String {
        switch self {
        case .popular: return "Popular"
        case .discover: return "Discover"
        }
    }
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var productCollection: UICollectionView!
    
    private var popularProducts: [ProductDetails] = []
    private var discoverProducts: [ProductDetails] = []

    // MARK: - Variables
    private var viewModel = HomeViewModel() // Bind the viewModel
    private var progressViewHandler: ProgressViewHandler!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        productCollection.collectionViewLayout = createCompositionalLayout()
        setupUI()
        observeViewModel()
    }
    
    // MARK: - Config UI for this view
    private func setupUI() {
        productCollection.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionCell")
        productCollection.register(UINib(nibName: "SectionHeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "DiscoverSection"
        )


        productCollection.dataSource = self
        productCollection.delegate = self
        navigationItem.searchController = viewModel.searchBarController.searchController
       
        
        progressViewHandler = ProgressViewHandler(on: productCollection, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))
    }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           productCollection.collectionViewLayout.invalidateLayout()
       }

    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = HomeSection(rawValue: sectionIndex) ?? .discover

            switch section {
            case .popular:
                // HORIZONTAL SCROLLING SECTION
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(140), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                let header = self.createSectionHeader(
                    withInsets: NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
                )
                sectionLayout.boundarySupplementaryItems = [header]

                return sectionLayout

            case .discover:
                // Vertical grid layout with dynamic column count
                let spacing: CGFloat = 5        // spacing *between* items
                let edgePadding: CGFloat = 10   // spacing at left and right edges

                let availableWidth = environment.container.effectiveContentSize.width
                let minColumnWidth: CGFloat = 160
                let maxNumColumns = floor((availableWidth + spacing - (edgePadding * 2)) / (minColumnWidth + spacing))
                let numberOfColumns = max(1, maxNumColumns)
                let fractionalWidth = 1.0 / numberOfColumns

                let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(fractionalWidth),
                        heightDimension: .fractionalWidth(fractionalWidth * 1.5)
                    )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2, leading: spacing / 2, bottom: spacing / 2, trailing: spacing / 2)

                let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(300)
                    )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    group.interItemSpacing = .fixed(spacing)
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.interGroupSpacing = spacing

               
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: edgePadding, bottom: 0, trailing: edgePadding)

                let header = self.createSectionHeader(
                                withInsets: NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10)
                            )
                       sectionLayout.boundarySupplementaryItems = [header]

                    return sectionLayout
                }
            }
           }
    private func createSectionHeader(withInsets insets: NSDirectionalEdgeInsets = .zero) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = insets
        return header
    }


    // MARK: - Subscribers
    private func observeViewModel() {
        viewModel.$filteredProductLists
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] products in
                        guard let self = self else { return }

                        self.popularProducts = Array(products.sorted(by: { $0.rating.count > $1.rating.count }).prefix(10))
                        self.discoverProducts = products.filter { product in
                            !self.popularProducts.contains(where: { $0.id == product.id })
                        }
                        self.productCollection.reloadData()
                    }
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

    }
    
    @objc func refresh() {
        print("Pulled to refresh!")
        viewModel.refreshProducts()
    }
    
    
    // MARK: - Populate the tableView, Delegates and DataSource
    // Determine the rows of the table view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // 0 = Popular, 1 = Discover
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? popularProducts.count : discoverProducts.count
    }
    
    // Configure the UI for a specific cell and populate it
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = productCollection.dequeueReusableCell(withReuseIdentifier: "ProductCollectionCell", for: indexPath) as! HomeCollectionViewCell
        let product = indexPath.section == 0 ? popularProducts[indexPath.row] : discoverProducts[indexPath.row]

        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        ProductImageManager.loadImage(into: cell.prodImageView, from: product.image)
        cell.prodCategory.text = product.category

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = indexPath.section == 0 ? popularProducts[indexPath.row] : discoverProducts[indexPath.row]

        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let productDetailsViewModel = ProductDetailsViewModel(product: selectedProduct)
            productDetailsVC.viewModel = productDetailsViewModel
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
    // MARK: - Header View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "DiscoverSection",
            for: indexPath
        ) as! SectionHeaderCollectionReusableView

        let sectionTitle = indexPath.section == 0 ? "Popular Products" : "Discover"
        header.configure(with: sectionTitle)
        return header
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let width = collectionView.bounds.width

        if indexPath.section == 0 {
            return CGSize(width: 160, height: 240)
        } else {
            let totalSpacing = spacing * 1 + 16 // if 2 columns, 1 gap + insets
            let itemWidth = (width - totalSpacing) / 2
            return CGSize(width: itemWidth, height: itemWidth * 1.5)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
    // MARK: - Functions for Button Actions
    // Function to Navigate to the Cart View
    @IBAction func gotoCartItemsAction(_ sender: Any) {
        if let shoppingCartVC = storyboard?.instantiateViewController(withIdentifier: "ShoppingCartViewController") as? ShoppingCartViewController {
            let shoppingCartViewModel = ShoppingCartViewModel()
            shoppingCartVC.viewModel = shoppingCartViewModel
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
