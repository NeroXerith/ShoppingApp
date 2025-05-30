//
//  UserProfileController.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/25/25.
//

import UIKit
import SwiftUI

class UserProfileController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply Tab Bar appearance for the UserProfile tab
        if let tabBarController = self.tabBarController {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .regular)  // Apply Blur effect
            appearance.backgroundColor = .clear
            
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }

        // SwiftUI View
        let userProfileSwiftUIView = UserProfile()
        // Embed SwiftUI to UIKit View Controller
        let hostingController = UIHostingController(rootView: userProfileSwiftUIView)

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
