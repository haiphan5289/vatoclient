//  File name   : HomeSuggestionVM.swift
//
//  Author      : Vato
//  Created date: 9/17/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import FwiCoreRX
import RxSwift
import UIKit

final class HomeSuggestionVM: GenericCollectionViewCellVM<HomeSuggestionCVC, PlaceModel> {
    /// Class's public properties.
    
    /// Class's constructors.
    override init(with collectionView: UICollectionView?) {
        super.init(with: collectionView)
//        items = [
//            "Gate 1 - Tan Son Nhat",
//            "Gate 2",
//            "Gate 3 - Tan"
//        ]
    }

    // MARK: Class's public override methods
    override func configure(forCell cell: HomeSuggestionCVC, with item: PlaceModel) {
        cell.titleLabel.text = item.name
        cell.iconImageView.image = UIImage(named: item.getIconName())
        cell.titleLabel.font = font
        
        cell.titleLabel.textColor = Color.greyishBrown
        
        if item.typeId == .AddNew {
            cell.iconImageView.tintColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            cell.titleLabel.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        }
        
    }
    
    // MARK: UICollectionViewDataSource's members
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = HomeSuggestionCVC.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        
        if let item: PlaceModel = self[indexPath] {
            configure(forCell: cell, with: item)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout's members
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = self[indexPath] else {
            return CGSize.zero
        }

        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font
        ]
        let string = NSAttributedString(string: item.name ?? "", attributes: attributes)

        // Calculate dynamic width
        var expectedSize = string.size()
        expectedSize.width = ceil(expectedSize.width + 64.0)
        
        let width35 = UIScreen.main.bounds.size.width * 3 / 5
        let width = expectedSize.width >= width35 ? width35 : expectedSize.width

        return CGSize(width: width , height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }

    /// Class's private properties.
    private let font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
    private let height: CGFloat = 40.0
}

// MARK: Class's public methods
extension HomeSuggestionVM {
    func update(newItems items: [PlaceModel]) {
        self.items = ArraySlice<PlaceModel>(items)
        collectionView?.reloadData()
    }
}

// MARK: Class's private methods
private extension HomeSuggestionVM {}
