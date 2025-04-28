//
//  FavoritesViewController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/28/25.
//

import UIKit
import SwiftUI

class FavoritesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSwiftUIView()
    }
    
    private func showSwiftUIView() {
        // SwiftUI View
        let favoriteSwiftUIView = Favorites()
        // Embed SwiftUI to UIKit View Controller
        let hostingController = UIHostingController(rootView: favoriteSwiftUIView)
        addChild(hostingController)
    
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
