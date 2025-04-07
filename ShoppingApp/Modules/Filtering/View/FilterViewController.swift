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
    var applyFilter: ((SortOption, Double, Double) -> Void)?

    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    private func bindUI() {
        sortSegmentedControl.selectedSegmentIndex = 0
        
        sortSegmentedControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
    }
    
    @objc func sortChanged() {
        viewModel.sortOption = sortSegmentedControl.selectedSegmentIndex == 0 ? .ascending : .descending
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        let min = Double(minPriceTextField.text ?? "") ?? 0
        let max = Double(maxPriceTextField.text ?? "") ?? 100000
        
        viewModel.minPrice = min
        viewModel.maxPrice = max
        
        applyFilter?(viewModel.sortOption, viewModel.minPrice, viewModel.maxPrice)
        
        dismiss(animated: true)
    }
}
