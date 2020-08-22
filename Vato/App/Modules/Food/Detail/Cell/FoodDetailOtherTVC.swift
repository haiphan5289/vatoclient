//  File name   : FoodDetailOtherTVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

final class FoodDetailOtherTVC: UITableViewCell, UpdateDisplayProtocol {
    struct Configs {
        static let title = "Hình ảnh khác"
    }
    /// Class's public properties.
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var hCollectionView: NSLayoutConstraint?
    private var dispose: Disposable?
    /// Class's private properties.
    
    private var hItem: CGFloat = 0
    
    func setupDisplay(item: [String]?) {
        let items = item ?? []
        let h = items.count >= 8 ? hItem * 2 + 8 : hItem
        hCollectionView?.constant = h + 2
        contentView.layoutIfNeeded()
        dispose = Observable.just(items).bind(to: collectionView.rx.items(cellIdentifier: FoodDetailOtherCVC.identifier, cellType: FoodDetailOtherCVC.self)) { idx, element, cell in
            cell.setupDisplay(item: element)
        }
    }
}

// MARK: Class's public methods
extension FoodDetailOtherTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dispose?.dispose()
        localize()
    }
}

// MARK: Class's private methods
private extension FoodDetailOtherTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        lblTitle?.text = Configs.title
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        let w = (UIScreen.main.bounds.width - 56) / 4
        hItem = w
        layout?.itemSize = CGSize(width: w, height: w)
        layout?.minimumLineSpacing = 8
        layout?.minimumInteritemSpacing = 8
        layout?.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        contentView.addSeperator()
        contentView.addSeperator(with: .zero, position: .top)
    }
}
