//
//  ShoppingListViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import UIKit
import Kingfisher

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Segue Outlets
    @IBOutlet weak var productTable: UITableView!
    
    
    // MARK: - Variables
    private var productFetcher =  FetchProducts() // Handles API alls to fetch product data
    private var productLists = [ProductDetails](){
        didSet {
            productTable.reloadData()
            progressViewHandler.hideProgressView()
        }
    } // Holds/Stores all the fetched products
    private var progressViewHandler: ProgressViewHandler! // Handles the loading indicator

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProducts()
    }
    
    
    // MARK: - Functions
    // Setup the UI for this view
    func setupUI(){
        productTable.dataSource = self
        productTable.delegate = self
        
        progressViewHandler = ProgressViewHandler(on: productTable, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))
    }
    
    // Function to Navigate to the Cart view
    @IBAction func gotoShoppingCartAction(_ sender: UIButton) {
        if let shoppingCartVC = storyboard?.instantiateViewController(withIdentifier: "ShoppingCartViewController") as? ShoppingCartViewController {
            navigationController?.pushViewController(shoppingCartVC, animated: true)
        }
    }
    
    // Refreshes the product lists when user pulls the screen to refresh
    @objc func refresh() {
        progressViewHandler.showProgressView(with: 0.1)
        print("Pulled to Refresh!")
        fetchProducts()
    }
    
    // Function to fetch data and Update the productTable View
    func fetchProducts() {
        progressViewHandler.showProgressView()
        productFetcher.fetchProducts { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let products):
                        self?.productLists = products
                        self?.productTable.reloadData() // Refreshes the table
                        self?.progressViewHandler.showProgressView(with: 1.0)
                    case .failure(let error):
                        print("Failed to fetch products: \(error.localizedDescription)")
                        self?.progressViewHandler.hideProgressView()
                    }
                }
            }
        }
    
    // MARK: - TableView Delagates and DataSource
    
    // Determine the rows of the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }
    
    // Configure the UI for a specific cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        let product = productLists[indexPath.row]
        
        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        
        ProductImageManager.loadImage(into: cell.prodImageView, from: product.image)
        
        cell.prodCategory.text = product.category
        
        return cell
    }
    
    // Navigates to the product detials screen when a row/cellr is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = productLists[indexPath.row]
        
        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            productDetailsVC.selectedProduct = selectedProduct
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
}
