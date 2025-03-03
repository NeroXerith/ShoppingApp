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
    
    private var cartProducts: [CartModel] = []
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
    
    // MARK: - Update Total Price
    private func updateTotalPrice() {
        let total = cartProducts.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
//        totalLabel.text = "Total: $\(String(format: "%.2f", total))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        let cartItem = cartProducts[indexPath.row]
        let product = cartItem.product
        cell.prodNameLabel.text = product.title
        cell.prodCategoryLabel.text = product.category
        cell.prodPriceLabel.text = "$\(String(product.price))"
        cell.prodQtyLabel.text = "\(cartItem.quantity)"
        
        
        // Fetch product image asynchronously
        GetProductImage().fetchImage(from: product.image) { image in
            DispatchQueue.main.async {
                cell.prodImageHolder.image = image
            }
        }
        
        cell.updateQuantityHandler = { increase in
                    if increase {
                        CartManager.shared.increaseQuantity(product.id)
                    } else {
                        CartManager.shared.decreaseQuantity(product.id)
                    }
                    self.loadCartItems()
                }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = cartProducts[indexPath.row].product
            CartManager.shared.removeFromCart(product.id)
            loadCartItems()
        }
    }
    
    
}
