//
//  CategoryTagsView.swift
//  Vato
//
//  Created by khoi tran on 11/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class CategoryTagsViewCell: UICollectionViewCell {
    private (set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    private (set) lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    private (set) lazy var selectImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            self.shouldSelect = self.isSelected
        }
    }
    
    var shouldSelect: Bool? {
        didSet {
            if self.shouldSelect != nil {
                if self.shouldSelect! {
                    bgView.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.14)
                    selectImageView.image = UIImage(named: "ic_category_selected")
                } else {
                    bgView.backgroundColor = UIColor(red: 242/255, green: 244/255, blue: 245/255, alpha: 1.0)
                    selectImageView.image = UIImage(named: "ic_category_deSelected")
                    }
                
                }
        }
    }
    
    private func visualize() {
        bgView >>> contentView >>> {
            $0.cornerRadius = 4
            $0.clipsToBounds = true
            $0.backgroundColor = UIColor(red: 242/255, green: 244/255, blue: 245/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        selectImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_category_deSelected")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(8)
                make.width.equalTo(20)
                make.height.equalTo(20)                
            })
        }
        
        titleLabel >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(selectImageView.snp.right).offset(8)                
            })
        }
    }
    
}

protocol CategoryDisplayItemView {
    var name: String? { get }
    var id: Int? { get }
}

final class CategoryTagsView: UIView, UpdateDisplayProtocol {
    private var collectionView: UICollectionView!
    private lazy var candidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    private var source: [CategoryDisplayItemView] = []
    private var listSelected: [CategoryDisplayItemView] = []
    
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
    
    func setupDisplay(item: [CategoryDisplayItemView]?, listSelected: [CategoryDisplayItemView]?) {
        let listSelectedCategory = listSelected ?? []
        self.listSelected = listSelectedCategory
        self.setupDisplay(item: item?.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.id ?? 0 < rhs.id ?? 0
        }))
    }
    
    func setupDisplay(item: [CategoryDisplayItemView]?) {
        let items = item ?? []
        source = items
        Observable.just(items).bind(to: collectionView.rx.items(cellIdentifier: CategoryTagsViewCell.identifier, cellType: CategoryTagsViewCell.self)) { [weak self] idx, element, cell in
            guard let me = self else { return }
            cell.titleLabel.text = element.name
            if !me.listSelected.filter({ $0.id == element.id }).isEmpty {
                if cell.shouldSelect == nil {

                    cell.shouldSelect = true
                    
                    me.collectionView.selectItem(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .left)
                    cell.isSelected = true
                }
            }
            }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var selectedIndexPaths: [IndexPath]? {
        return collectionView.indexPathsForSelectedItems
    }
    
    var selectedItems: [CategoryDisplayItemView]? {
        return selectedIndexPaths?.compactMap({ (idx) -> CategoryDisplayItemView? in
            source[safe: idx.item]
        })
    }
    
    func updateSelectionStyle(allowsMultipleSelection: Bool = true) {
        collectionView.allowsMultipleSelection = allowsMultipleSelection
    }
}

// MARK: Class's public methods
extension CategoryTagsView: TagCellLayoutDelegate {
    func tagCellLayoutTagSize(layout: TagCellLayout, atIndex index: Int) -> CGSize {
        guard let element = source[safe: index] else {
            return .zero
        }
        candidateLabel.text = element.name
        candidateLabel.sizeToFit()
        let f = candidateLabel.frame
        return CGSize(width: f.size.width + 44, height: f.size.height + 14)
    }
    
    func tagCellLayoutInteritemHorizontalSpacing(layout: TagCellLayout) -> CGFloat {
        return 16
    }
    
    func tagCellLayoutInteritemVerticalSpacing(layout: TagCellLayout) -> CGFloat {
        return 16
    }
}


// MARK: Class's private methods
private extension CategoryTagsView {
    private func visualize() {
        // todo: Visualize view's here.
        let tagCellLayout  = TagCellLayout(alignment: .left, delegate: self)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        collectionView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView?.register(CategoryTagsViewCell.self, forCellWithReuseIdentifier: CategoryTagsViewCell.identifier)
        
        collectionView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
               make.edges.equalToSuperview()
            })
        }
        
//        let bottom = UIApplication.shared.keyWindow?.edgeSafe.bottom ?? 0
//        let top = UIApplication.shared.keyWindow?.edgeSafe.top ?? 0
//
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: top + bottom + 100, right: 0)
//
        
    }
    
    func setupRX() {
    }
}
