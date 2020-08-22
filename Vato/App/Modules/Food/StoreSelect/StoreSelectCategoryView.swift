//  File name   : StoreSelectCategoryView.swift
//
//  Author      : Dung Vu
//  Created date: 11/22/19
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

fileprivate final class StoreSelectCategoryCVC: UICollectionViewCell, UpdateDisplayProtocol {
    private lazy var lblContent: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var bgView: UIView = {
        let v = UIView(frame: .zero)
        return v
    }()
    
    override var isSelected: Bool {
        didSet {
            lblContent.textColor = colorText()
            bgView.backgroundColor = colorBackground()
        }
    }
    
    func setupDisplay(item: StoreCategoryDisplayProtocol?) {
        lblContent.text = item?.name
        self.layoutSubviews()
    }
    
    private func colorBackground() -> UIColor {
        return isSelected ? #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.1)
    }
    
    private func colorText() -> UIColor {
        return isSelected ? #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        bgView >>> contentView >>> {
            $0.clipsToBounds = true
            $0.backgroundColor = colorBackground()
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        lblContent >>> contentView >>> {
            $0.textColor = colorText()
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = contentView.bounds.height
        bgView.layer.cornerRadius = h / 2
    }
}

protocol StoreCategoryDisplayProtocol {
    var name: String? { get }
}

final class StoreSelectCategoryView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    
    private var collectionView: UICollectionView!
    private (set) var source: [StoreCategoryDisplayProtocol] = []
    private lazy var candidateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    private lazy var disposeBag = DisposeBag()
    var selected: Observable<Int> {
        return eSelected.map { $0.item }
    }
    
    private lazy var eSelected: PublishSubject<IndexPath> = PublishSubject()
    
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = .white
        let tagCellLayout = UICollectionViewFlowLayout()
        tagCellLayout.minimumLineSpacing = 8
        tagCellLayout.minimumInteritemSpacing = 8
        tagCellLayout.scrollDirection = .horizontal
        tagCellLayout.sectionInset = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagCellLayout)
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(8)
                make.height.equalTo(32)
            })
        }
        collectionView.register(StoreSelectCategoryCVC.self, forCellWithReuseIdentifier: StoreSelectCategoryCVC.identifier)
    }
    
    private func setupRX() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.rx.itemSelected.bind(onNext: weakify({ (idx, wSelf) in
            wSelf.eSelected.onNext(idx)
            wSelf.select(at: idx.item)
        })).disposed(by: disposeBag)
    }
}

// MARK: - Public
extension StoreSelectCategoryView: Weakifiable {
    func setupDisplay(item: [StoreCategoryDisplayProtocol]?) {
        guard let items = item else { return }
        source = items
        Observable.just(items).bind(to: collectionView.rx.items(cellIdentifier: StoreSelectCategoryCVC.identifier, cellType: StoreSelectCategoryCVC.self)) { idx, item, cell in
            cell.setupDisplay(item: item)
        }.disposed(by: disposeBag)
    }
    
    func select(at index: Int) {
        guard 0..<source.count ~= index else {
            return
        }
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
}


extension StoreSelectCategoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let text = source[safe: indexPath.item]?.name else {
            return .zero
        }
        candidateLabel.text = text
        candidateLabel.sizeToFit()
        let f = candidateLabel.frame
        return CGSize(width: f.size.width + 31, height: f.size.height + 16)
    }
}


