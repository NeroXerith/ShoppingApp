//
//  ShoppingListViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    // MARK: - Segue Outlets
    @IBOutlet weak var productTable: UITableView!
    
    // MARK: - Variables
    private let fetchProdImage = GetProductImage()
    private var productFetcher =  FetchProducts()
    private var productLists = [ProductDetails]() {
        didSet {
            productTable.reloadData()
            progressViewHandler.hideProgressView()
        }
    }

    private var progressViewHandler: ProgressViewHandler!

    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productTable.dataSource = self
        productTable.delegate = self

        progressViewHandler = ProgressViewHandler(on: productTable, navigationBar: navigationController?.navigationBar)
        progressViewHandler.addRefreshAction(target: self, action: #selector(refresh))

        fetchProducts()
    }
    
    
    // MARK: - Functions
    @objc func refresh() {
        progressViewHandler.showProgressView(with: 0.1)
        print("Pulled to Refresh!")
        fetchProducts()
    }

    func fetchProducts() {
        progressViewHandler.showProgressView()
        
        productFetcher.fetchProducts { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let products):
                        self?.productLists = products
                        self?.progressViewHandler.showProgressView(with: 1.0)
                    case .failure(let error):
                        print("Failed to fetch products: \(error.localizedDescription)")
                        self?.progressViewHandler.hideProgressView()
                    }
                }
            }
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        let product = productLists[indexPath.row]
        
        cell.prodNameLabel.text = product.title
        cell.prodPriceLabel.text = "$\(String(product.price))"
        
        fetchProdImage.fetchImage(from: product.image) { image in
            cell.prodImageView.image = image
        }
        
        cell.prodCategory.text = product.category
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = productLists[indexPath.row]
        
        if let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
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
