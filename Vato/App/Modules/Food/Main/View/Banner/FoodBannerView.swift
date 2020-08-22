//  File name   : FoodBannerView.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import FwiCore
import RxCocoa
import FwiCoreRX
import SnapKit
import Atributika

protocol CleanActionProtocol {
    func cleanAction()
}

final class FoodBannerView: UIView, DisplayStaticHeightProtocol, UpdateDisplayProtocol, HandlerValueProtocol, LazyDisplayImageProtocol, CleanActionProtocol {
    static var height: CGFloat { return 280 }
    static var bottom: CGFloat { return 0 }
    static var automaticHeight: Bool { return false }
    
    var callback: BlockAction<ImageDisplayProtocol>?
    /// Class's public properties.
    @IBOutlet var containerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var lblNumberPromotion: UILabel?
    @IBOutlet var btnDetailPromotion: UIButton?
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var heightConstraintPromotion: NSLayoutConstraint?
    private lazy var disposeBag = DisposeBag()
    private var source: [ImageDisplayProtocol] = []
    private var disposeScroll: Disposable?
    private (set) var disposeUpdate: Disposable?
    
    @IBOutlet var listItemsHistory: [UIView]?
    
    private var currentIdx: Int = 0 {
        didSet {
            self.pageControl?.currentPage = currentIdx
        }
    }
    var roundAll: Bool = false
    
    /// Class's private properties.
    
    func showHistory() {
        listItemsHistory?.forEach { $0.isHidden = false }
    }
    
    func updateDisplay(text: Observable<String>?) {
        text?.bind(onNext: weakify({ (n, wSelf) in
            let b = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1))
            let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(.systemFont(ofSize: 14, weight: .regular))
            let att = n.style(tags: b).styleAll(all).attributedString
            wSelf.lblNumberPromotion?.attributedText = att
        })).disposed(by: disposeBag)
    }
    
    func setupDisplay(item: [ImageDisplayProtocol]?) {
        let item = item ?? []
        source = item
        currentIdx = 0
        disposeUpdate?.dispose()
        disposeUpdate = Observable.just(item).observeOn(MainScheduler.asyncInstance).bind(to: collectionView.rx.items(cellIdentifier: FoodBannerCVC.identifier, cellType: FoodBannerCVC.self)) { idx, element, cell in
            cell.setupDisplay(item: element)
        }
        pageControl?.numberOfPages = item.count
        setupAutoScroll()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        cleanAction()
    }
    
    func displayImage() {}
    func cleanAction() {
       disposeScroll?.dispose()
    }
}

// MARK: Class's public methods
extension FoodBannerView: Weakifiable {
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

// MARK: Class's private methods
extension FoodBannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        let s = CGSize(width: w, height: 200)
        return s
    }
}

private extension FoodBannerView {
    private func initialize() {
        // todo: Initialize view's here
        heightConstraintPromotion?.constant = 0
        pageControl?.hidesForSinglePage = true
        collectionView?.register(FoodBannerCVC.nib, forCellWithReuseIdentifier: FoodBannerCVC.identifier)
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumLineSpacing = 0
        layout?.minimumInteritemSpacing = 0
        layout?.sectionInset = .zero
        collectionView.showsHorizontalScrollIndicator = false
        
        let gradient = BookingConfirmGradientView(frame: .zero)
        containerView.insertSubview(gradient, belowSubview: pageControl)
        gradient >>> {
            $0.colors = [UIColor(white: 1, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor]
            $0.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(60)
            }
        }
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        guard !roundAll else {
            containerView.layer.cornerRadius = 8
            containerView.clipsToBounds = true
            return
        }
        let rect = containerView.bounds
        let benzier = UIBezierPath(rect: rect)//UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.frame = rect
        shape.fillColor = UIColor.blue.cgColor
        shape.path = benzier.cgPath
        containerView.layer.mask = shape
        
        btnDetailPromotion?.setTitle(Text.seeMore.localizedText, for: .normal)
    }
    
    private func setupAutoScroll() {
        disposeScroll?.dispose()
        guard !source.isEmpty else {
            return
        }
        disposeScroll = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (_, wSelf) in
            var next = wSelf.currentIdx + 1
            let count = wSelf.source.count
            next = next <= count - 1 ? next : 0
            wSelf.currentIdx = next
            wSelf.collectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
        }))
    }
    
    func setupRX() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.rx.willBeginDragging.bind(onNext: weakify({ (wSelf) in
            wSelf.disposeScroll?.dispose()
        })).disposed(by: disposeBag)
        
        collectionView.rx.didEndDecelerating.bind(onNext: weakify({ (wSelf) in
            let offset = wSelf.collectionView.contentOffset
            let w = wSelf.collectionView.bounds.width
            let p = (offset.x / w).rounded(.toNearestOrAwayFromZero)
            wSelf.currentIdx = Int(p)
            wSelf.setupAutoScroll()
        })).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.map { [weak self] in  self?.source[safe: $0.item] }.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.callback?(item)
        })).disposed(by: disposeBag)
    }
}
