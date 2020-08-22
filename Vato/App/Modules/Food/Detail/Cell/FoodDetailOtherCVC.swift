//  File name   : FoodDetailOtherCVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class FoodDetailOtherCVC: UICollectionViewCell, UpdateDisplayProtocol {
    /// Class's public properties.

    /// Class's private properties.
    @IBOutlet var imageView: UIImageView?
    
    func setupDisplay(item: ImageDisplayProtocol?) {
        imageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 79, height: 79))
    }
}

// MARK: Class's public methods
extension FoodDetailOtherCVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
}

// MARK: Class's private methods
private extension FoodDetailOtherCVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
