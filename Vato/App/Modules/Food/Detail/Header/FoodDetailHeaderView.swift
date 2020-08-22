//  File name   : FoodDetailHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import GSKStretchyHeaderView
import RxSwift
import RxCocoa
import SnapKit
import FwiCore

final class FoodDetailHeaderView: UIView, UpdateDisplayProtocol, Weakifiable {
    struct Configs {
        static let space: CGFloat = 24
        static let maxH: CGFloat = 200
        static let corner: CGFloat = 16
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var hStackView: NSLayoutConstraint?
    @IBOutlet var containerView: UIView!
    @IBOutlet var btnDetailMap: UIButton?
    
    private lazy var disposeBag = DisposeBag()
    private var disposeScroll: Disposable?
    private var numberItems: Int = 0 {
        didSet {
            pageControl?.numberOfPages = numberItems
        }
    }
    private var currentIdx: Int = 0 {
        didSet {
            self.pageControl?.currentPage = currentIdx
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.showsHorizontalScrollIndicator = false
        pageControl?.hidesForSinglePage = true
        setupRX()
    }
    
    private func setupAutoScroll() {
        disposeScroll?.dispose()
        guard numberItems > 1 else {
            return
        }
        disposeScroll = Observable<Int>.interval(5, scheduler: MainScheduler.instance).bind(onNext: weakify({ (_, wSelf) in
            var next = wSelf.currentIdx + 1
            let count = wSelf.numberItems
            next = next <= count - 1 ? next : 0
            wSelf.currentIdx = next
            let w = UIScreen.main.bounds.width
            let rect = CGRect(x: CGFloat(next) * w, y: 0, width: w, height: Configs.maxH)
            wSelf.scrollView.scrollRectToVisible(rect, animated: true)
        }))
    }
    
    private func setupRX() {
        
//        scrollView.rx.observe(CGSize.self, #keyPath(UIScrollView.contentSize)).bind { (s) in
//            print(s ?? .zero)
//        }.disposed(by: disposeBag)
        
        scrollView.rx.willBeginDragging.bind(onNext: weakify({ (wSelf) in
            wSelf.disposeScroll?.dispose()
        })).disposed(by: disposeBag)
        
        scrollView.rx.didEndDecelerating.bind(onNext: weakify({ (wSelf) in
            let offset = wSelf.scrollView.contentOffset
            let p = (offset.x / UIScreen.main.bounds.width).rounded(.toNearestOrAwayFromZero)
            wSelf.currentIdx = Int(p)
            wSelf.setupAutoScroll()
        })).disposed(by: disposeBag)
    }
    
    func setupDisplay(item: [String]?) {
        numberItems = item?.count ?? 0
        if let views = stackView?.arrangedSubviews, !views.isEmpty {
            views.forEach {
                stackView?.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
        let h = stackView?.bounds.height ?? 0
        let size = CGSize(width: UIScreen.main.bounds.width, height: h)
        item?.forEach { url in
            let imageView = UIImageView(frame: .zero)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.setImage(from: url, placeholder: UIImage(named: "ic_placeholder_product"), size: size)
            imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            imageView.snp.makeConstraints({ (make) in
                make.width.equalTo(size.width)
            })
            stackView?.addArrangedSubview(imageView)
        }
        setupAutoScroll()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds
        hStackView?.constant = r.height - 24
        visualize()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        disposeScroll?.dispose()
    }
}

// MARK: Class's private methods
private extension FoodDetailHeaderView {
    private func visualize() {
        // todo: Visualize view's here
        let rect = containerView.bounds
        let ratio = min(rect.height / 200, 1)
        if ratio < 0.5 {
            containerView.layer.mask = nil
        } else {
            let v = 16 * ratio
            let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: v, height: v))
            let shape = CAShapeLayer()
            shape.frame = rect
            shape.fillColor = UIColor.blue.cgColor
            shape.path = benzier.cgPath
            containerView.layer.mask = shape
        }
    }
}

final class FoodDetailContentHeaderView: GSKStretchyHeaderView {
    /// Class's public properties.
    private (set) lazy var view = FoodDetailHeaderView.loadXib()
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        minimumContentHeight = edge.top + 68
        maximumContentHeight = 224
        view >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        view.hStackView?.constant = max(200 * stretchFactor, minimumContentHeight)
    }
}




