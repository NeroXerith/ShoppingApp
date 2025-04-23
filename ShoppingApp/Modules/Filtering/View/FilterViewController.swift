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
    var applyFilter: ((SortOption, SortOption, Double, Double, Bool, Bool) -> Void)?
    
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var priceSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var checkButtonPriceBy: UIButton!
    @IBOutlet weak var checkButtonPriceRange: UIButton!
    
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
        
        viewModel.$isPriceByChecked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChecked in
                self?.updateCheckButton(self?.checkButtonPriceBy, isChecked: isChecked)
                self?.priceSortSegmentedControl.isEnabled = isChecked
            }.store(in: &cancellables)
        
        viewModel.$isPriceRangeChecked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChecked in
                self?.updateCheckButton(self?.checkButtonPriceRange, isChecked: isChecked)
                self?.minPriceTextField.isEnabled = isChecked
                self?.maxPriceTextField.isEnabled = isChecked
            }.store(in: &cancellables)
    }
    
    @objc func titleSortChanged() {
        viewModel.titleSortOption = sortSegmentedControl.selectedSegmentIndex == 0 ? .ascending : .descending
    }

    @objc func priceSortChanged() {
        viewModel.priceSortOption = priceSortSegmentedControl.selectedSegmentIndex == 0 ? .lowestToHighest : .highestToLowest
    }
    
    @IBAction func checkButtonPriceByTapped(_ sender: Any) {
        viewModel.isPriceByChecked.toggle()
    }
    
    @IBAction func checkButtonPriceRangeTapped(_ sender: Any) {
        viewModel.isPriceRangeChecked.toggle()
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        let min = Double(minPriceTextField.text ?? "") ?? 0
        let max = Double(maxPriceTextField.text ?? "") ?? 100000
        
        viewModel.minPrice = min
        viewModel.maxPrice = max
        
        applyFilter?(viewModel.titleSortOption,
                     viewModel.priceSortOption,
                     viewModel.minPrice,
                     viewModel.maxPrice,
                     viewModel.isPriceByChecked,
                     viewModel.isPriceRangeChecked)
            
        dismiss(animated: true)
    }
    
    // Utility to update the button state
    private func updateCheckButton(_ button: UIButton?, isChecked: Bool){
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        button?.setImage(UIImage(systemName: imageName), for: .normal)
        button?.tintColor = isChecked ? .systemBlue : .lightGray
    }
}
