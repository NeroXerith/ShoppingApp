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
    
    private var viewModel = ShoppingCartViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views Lifecycle
    // Firs load Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCartTableView()
        observeViewModel()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Functions
    // Setup TableView
    private func setupCartTableView() {
        cartTableView.delegate = self
        cartTableView.dataSource = self
    }
    
    private func observeViewModel() {
        viewModel.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.cartTableView.reloadData()
                self?.updateCartUI()
            }
            .store(in: &cancellables)
        
        viewModel.$total
            .assign(to: \.text!, on: totalCountLabel)
            .store(in: &cancellables)
    }

    private func updateCartUI(){
        emptyCartLabel.isHidden = !viewModel.cartItems.isEmpty
    }
    
    // MARK: - TableView Delegates and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        let cartItem = viewModel.cartItems[indexPath.row]
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
                }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = viewModel.cartItems[indexPath.row].product
            CartManager.shared.removeFromCart(product.id)
        }
    }
    
    // MARK: - Functions for Button Actions
    @IBAction func applyVoucherButton(_ sender: Any) {
        guard !viewModel.cartItems.isEmpty else {
            return
        }
        guard let code = voucherTextfield.text, !code.isEmpty else {
            return
        }
        
        viewModel.applyDiscount(voucherCode: code)
        invalidCodeLabel.isHidden = code == "STRAT50%OFF" || code == "STRAT25%OFF"
    }
}
