//
//  ShoppingListViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/18/25.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableProductList: UITableView!
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableProductList.dequeueReusableCell(withIdentifier: "ProdListViewCell", for: indexPath) as! ProdListViewCell
        cell.prodNameLabel.text = "Test"
        cell.prodImageView.image = nil
        cell.prodPriceLabel.text = ""
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productLists.append(ProductDetails(name: "Banana", imageUrl: "None", price: 1.2))
        tableProductList.dataSource = self
        print(productLists)
        // Do any additional setup after loading the view.
    }

    }

