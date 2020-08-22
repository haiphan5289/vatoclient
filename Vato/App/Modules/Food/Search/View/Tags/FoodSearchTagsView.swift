//  File name   : FoodSearchTagsView.swift
//
//  Author      : Dung Vu
//  Created date: 11/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class FoodSearchTagsCVC: UICollectionViewCell {
    private (set) lazy var lblTitle: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let bgView = UIView(frame: .zero)
        bgView >>> contentView >>> {
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9607843137, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        lblTitle >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
    }
}

final class FoodSearchTagsView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    private var collectionView: UICollectionView!
    private lazy var candidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    private var source: [String] = []
    private lazy var disposeBag = DisposeBag()
    private var mSelectTags = PublishSubject<String>()
    var selectedTag: Observable<String> {
        return mSelectTags
    }
    
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
        setupRX()
    }
    
    func setupDisplay(item: [String]?) {
        let items = item ?? []
        source = items
        Observable.just(items).bind(to: collectionView.rx.items(cellIdentifier: FoodSearchTagsCVC.identifier, cellType: FoodSearchTagsCVC.self)) { idx, element, cell in
            cell.lblTitle.text = element
        }.disposed(by: disposeBag)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Class's public methods
extension FoodSearchTagsView: TagCellLayoutDelegate {
    func tagCellLayoutTagSize(layout: TagCellLayout, atIndex index: Int) -> CGSize {
        guard let text = source[safe: index] else {
            return .zero
        }
        candidateLabel.text = text
        candidateLabel.sizeToFit()
        let f = candidateLabel.frame
        return CGSize(width: f.size.width + 24, height: f.size.height + 14)
    }
    
    func tagCellLayoutInteritemHorizontalSpacing(layout: TagCellLayout) -> CGFloat {
        return 12
    }
    
    func tagCellLayoutInteritemVerticalSpacing(layout: TagCellLayout) -> CGFloat {
        return 12
    }
}


// MARK: Class's private methods
private extension FoodSearchTagsView {
    private func visualize() {
        // todo: Visualize view's here.
        let tagCellLayout  = TagCellLayout(alignment: .left, delegate: self)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        collectionView.backgroundColor = .white
        collectionView?.register(FoodSearchTagsCVC.self, forCellWithReuseIdentifier: FoodSearchTagsCVC.identifier)
        
        collectionView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(28)
                make.height.equalTo(120)
                make.bottom.equalTo(-20).priority(.high)
            })
        }
    }
    
    func setupRX() {
        collectionView.rx.itemSelected.map { [weak self](idx) -> String? in
            self?.source[safe: idx.item]
        }.filterNil().bind(to: mSelectTags).disposed(by: disposeBag)
    }
}


