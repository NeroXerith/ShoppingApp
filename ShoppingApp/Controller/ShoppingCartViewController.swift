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
    @IBOutlet weak var subtotalCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var voucherTextfield: UITextField!
    @IBOutlet weak var invalidCodeLabel: UILabel!
    
    
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
        subtotalCountLabel.text = "$0.00"
        updateTotalPrice()
        // Show or hide empty cart message
        emptyCartLabel.isHidden = !cartProducts.isEmpty
        
    }
    
    // MARK: - Update Total Price
    private func updateTotalPrice() {
        let subTotal = cartProducts.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
        subtotalCountLabel.text = "$\(String(format: "%.2f", subTotal))"
        
        if let voucherCode = voucherTextfield.text, !voucherCode.isEmpty {
            applyDiscount(voucherCode: voucherCode, subTotal: subTotal)
        } else {
            totalCountLabel.text = subtotalCountLabel.text
        }
    }
    
    // MARK: - Apply Discount
    private func applyDiscount(voucherCode: String, subTotal: Double){
        var discountedTotal: Double = subTotal
       
        if voucherCode == "STRAT50%OFF" {
            invalidCodeLabel.isHidden = true
            discountedTotal = subTotal * 0.5
        } else if voucherCode == "STRAT25%OFF" {
            invalidCodeLabel.isHidden = true
            discountedTotal = subTotal * 0.75
        } else {
            invalidCodeLabel.isHidden = false
            voucherTextfield.text = ""
        }
        
        totalCountLabel.text = "$\(String(format: "%.2f", discountedTotal))"
        
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
