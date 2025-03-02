//
//  CartViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//

import UIKit

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var emptyCartLabel: UILabel!
    @IBOutlet weak var cartTableView: UITableView!
    
    private var cartProducts: [ProductDetails] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCartTableView()
        loadCartItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCartItems()  // Reload cart every time this view appears
    }
    
    // MARK: - Setup TableView
    private func setupCartTableView() {
        cartTableView.delegate = self
        cartTableView.dataSource = self
    }
    
    // MARK: - Load Cart Items
    private func loadCartItems() {
        cartProducts = CartManager.shared.getCartItems()
        cartTableView.reloadData()

        // Show or hide empty cart message
        emptyCartLabel.isHidden = !cartProducts.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        let product = cartProducts[indexPath.row]
        cell.prodNameLabel.text = product.title
        cell.prodCategoryLabel.text = product.category
        cell.prodPriceLabel.text = "$\(String(product.price))"
        
        // Fetch product image asynchronously
        GetProductImage().fetchImage(from: product.image) { image in
            DispatchQueue.main.async {
                cell.prodImageHolder.image = image
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = cartProducts[indexPath.row]
            CartManager.shared.removeFromCart(product.id)
            loadCartItems()
        }
    }
    
    
}
