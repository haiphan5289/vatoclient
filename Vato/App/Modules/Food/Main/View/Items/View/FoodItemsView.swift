//
//  FoodItemsView.swift
//  Vato
//
//  Created by Dung Vu on 10/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FoodItemsView: UIView, UpdateDisplayProtocol, DisplayStaticHeightProtocol, HandlerValueProtocol, LazyDisplayImageProtocol, Weakifiable {
    static var height: CGFloat { return 241 }
    static var bottom: CGFloat { return -16 }
    static var automaticHeight: Bool { return false }
    
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var btnMore: UIButton?
    @IBOutlet var collectionView: UICollectionView!
    private lazy var disposeBag = DisposeBag()
    var callback: BlockAction<FoodExploreItem>?
    private var source: [FoodExploreItem] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    
    private func visualize() {
        collectionView.register(FoodItemCVC.nib, forCellWithReuseIdentifier: FoodItemCVC.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupDisplay(item: Observable<[FoodExploreItem]>?) {
        item?.take(1).bind(onNext: weakify({ (list, wSelf) in
            wSelf.source = list
        })).disposed(by: disposeBag)
    }
    
    func displayImage() {
        collectionView.reloadData()
    }
}

extension FoodItemsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodItemCVC.identifier, for: indexPath) as? FoodItemCVC else {
            fatalError("Please implement!!!")
        }
        let i = source[indexPath.item]
        cell.setupDisplay(item: i)
        return cell
    }
}

extension FoodItemsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let item = self.source[safe: indexPath.item] else { return }
        self.callback?(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? LazyDisplayImageProtocol else { return }
        DispatchQueue.main.async {
            c.displayImage()
        }
    }
}
