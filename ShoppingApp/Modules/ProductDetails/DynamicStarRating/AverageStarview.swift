//
//  AverageStar.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 2/24/25.
//
import UIKit

class AverageStarView: UIView {
    private var starImageViews: [UIImageView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    private func setupStars() {
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .gray
            starImageViews.append(imageView)
            addSubview(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let starSize = bounds.height
        for (index, imageView) in starImageViews.enumerated() {
            imageView.frame = CGRect(x: CGFloat(index) * starSize, y: 0, width: starSize, height: starSize)
        }
    }
    
    func updateStarRating(rating: Double) {
        let fullStar = UIImage(systemName: "star.fill")
        let halfStar = UIImage(systemName: "star.leadinghalf.filled")
        let emptyStar = UIImage(systemName: "star")

        for (index, imageView) in starImageViews.enumerated() {
            let starIndex = Double(index)
            if rating > starIndex + 1 {
                imageView.image = fullStar
                imageView.tintColor = .orange
            } else if rating > starIndex {
                imageView.image = halfStar
                imageView.tintColor = .orange
            } else {
                imageView.image = emptyStar
                imageView.tintColor = .gray
            }
        }
    }
}
