//
//  ProgressVIew.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/26/25.
//

import UIKit

class ProgressViewHandler {
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!

    // MARK: - Initialization
    init(on scrollView: UIScrollView, navigationBar: UINavigationBar?) {
        setupProgressView(in: navigationBar)
        setupRefreshControl(for: scrollView)
    }

    // MARK: - Progress View Setup
    private func setupProgressView(in navigationBar: UINavigationBar?) {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .blue
        progressView.progress = 0.0
        progressView.isHidden = true
        
        if let navBar = navigationBar {
            navBar.addSubview(progressView)
            NSLayoutConstraint.activate([
                progressView.leadingAnchor.constraint(equalTo: navBar.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: navBar.trailingAnchor),
                progressView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
                progressView.heightAnchor.constraint(equalToConstant: 2)
            ])
        }
    }

    func showProgressView(with progress: Float = 0.1) {
        progressView.isHidden = false
        progressView.setProgress(progress, animated: true)
    }

    func hideProgressView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressView.isHidden = true
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - Refresh Control Setup
    private func setupRefreshControl(for scrollView: UIScrollView) {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        scrollView.refreshControl = refreshControl
    }

    func addRefreshAction(target: Any?, action: Selector) {
        refreshControl.addTarget(target, action: action, for: .valueChanged)
    }
}
