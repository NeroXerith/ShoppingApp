//
//  FilterViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/7/25.
//

import UIKit
import Combine

class FilterViewController: UIViewController {
    var viewModel = FilterViewModel()
    var applyFilter: ((SortOption, SortOption, Double, Double) -> Void)?

    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    private func bindUI() {
        // Title sorting
        sortSegmentedControl.selectedSegmentIndex = 0
        sortSegmentedControl.addTarget(self, action: #selector(titleSortChanged), for: .valueChanged)
        
        // Price sorting
        priceSortSegmentedControl.selectedSegmentIndex = 0
        priceSortSegmentedControl.addTarget(self, action: #selector(priceSortChanged), for: .valueChanged)
    }
    
    @objc func titleSortChanged() {
        viewModel.titleSortOption = sortSegmentedControl.selectedSegmentIndex == 0 ? .ascending : .descending
    }

    @objc func priceSortChanged() {
        viewModel.priceSortOption = priceSortSegmentedControl.selectedSegmentIndex == 0 ? .lowestToHighest : .highestToLowest
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        let min = Double(minPriceTextField.text ?? "") ?? 0
        let max = Double(maxPriceTextField.text ?? "") ?? 100000
        
        viewModel.minPrice = min
        viewModel.maxPrice = max
        
        applyFilter?(viewModel.titleSortOption, viewModel.priceSortOption, viewModel.minPrice, viewModel.maxPrice)
            
        dismiss(animated: true)
    }
}
