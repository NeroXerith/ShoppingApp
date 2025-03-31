//
//  ShoppingCartViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 3/31/25.
//

import Foundation
import UIKit
import Combine

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var emptyCartLabel: UILabel!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var subtotalCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var voucherTextfield: UITextField!
    @IBOutlet weak var invalidCodeLabel: UILabel!
    
    private var cartProducts: [CartModel] = []
    private var viewModel = ShoppingCartViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views Lifecycle
    // Firs load Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    // MARK: - Functions
    // Setup TableView
    private func setupUI() {
        cartTableView.delegate = self
        cartTableView.dataSource = self
    }
    

    
    // MARK: - TableView Delegates and Datasource
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
        
        ProductImageManager.loadImage(into: cell.prodImageHolder, from: product.image)
        
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
    
    // MARK: - Functions for Button Actions
    @IBAction func applyVoucherButton(_ sender: Any) {
        guard !cartProducts.isEmpty else {
            return
        }
        guard let voucherCode = voucherTextfield.text, !voucherCode.isEmpty else {
            return
        }
        
        let subTotal = cartProducts.reduce(0) { $0 + ($1.product.price * Double($1.quantity))}
        applyDiscount(voucherCode: voucherCode, subTotal: subTotal)
    }
}
