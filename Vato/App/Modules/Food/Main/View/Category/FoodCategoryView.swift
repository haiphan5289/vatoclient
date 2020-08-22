//  File name   : FoodCategoryView.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

final class FoodCategoryView: UIView, DisplayStaticHeightProtocol, UpdateDisplayProtocol, HandlerValueProtocol, LazyDisplayImageProtocol {
    struct Config {
        static let numberItemRow = 4
        static let numberItemColumn = 2
        static let numberItemPerPage = numberItemRow * numberItemColumn
    }
    
    var callback: BlockAction<FoodCategoryItem>?
    static var height: CGFloat { return 250 }
    static var bottom: CGFloat { return 0 }
    static var automaticHeight: Bool { return false }
    private var source: [FoodCategoryItem] = []
    /// Class's public properties.
    @IBOutlet var collectionView: UICollectionView!
    private lazy var disposeBag = DisposeBag()
    /// Class's private properties.
    
    func setupDisplay(item: [FoodCategoryItem]?) {
        let original = item ?? []
        var c = Array(original.prefix(7))
        if c.count == 7 {
            let item = FoodCategoryItem()
            c.append(item)
        }
        source = c
    }
    
    private func setupRX() {
        collectionView.rx.setDataSource(self).disposed(by: disposeBag)
        collectionView.rx.itemSelected.bind(onNext: weakify({ (idx, wSelf) in
            guard let cell = wSelf.collectionView.cellForItem(at: idx) as? FoodCategoryParentCVC,
                let item = cell.currentItem as? FoodCategoryItem else
            {
                return
            }
            wSelf.callback?(item)
        })).disposed(by: disposeBag)
    }
    
    func displayImage() {
        collectionView.reloadData()
    }
}

// MARK: Class's public methods
extension FoodCategoryView: Weakifiable {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        setupRX()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

extension FoodCategoryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodCategoryParentCVC.identifier, for: indexPath) as? FoodCategoryParentCVC else {
            fatalError("Please Implement")
        }
        
        let index = indexPath.item
//        let page = index / Config.numberItemPerPage
//        let indexInPage = index - page * Config.numberItemPerPage
//        let row = indexInPage % Config.numberItemColumn
//        let column = indexInPage / Config.numberItemColumn
//
//        let dataIndex = row * Config.numberItemRow + column + page * Config.numberItemPerPage
        cell.setupDisplay(item: source[safe: index])
        return cell
    }
    
}

// MARK: Class's private methods
private extension FoodCategoryView {
    private func initialize() {
        // todo: Initialize view's here.
        collectionView.register(FoodCategoryParentCVC.nib, forCellWithReuseIdentifier: FoodCategoryParentCVC.identifier)
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        let maxItem = CGFloat(Config.numberItemRow)
        let w = ((UIScreen.main.bounds.width - 32) - (maxItem - 1) * 8) / maxItem
        layout?.itemSize = CGSize(width: w, height: 100)
        layout?.minimumLineSpacing = 8
        layout?.minimumInteritemSpacing = 8
        layout?.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
