//  File name   : VatoSegmentView.swift
//
//  Author      : Dung Vu
//  Created date: 5/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol VatoSegmentChildProtocol: UIView {
    var isSelected: Bool { get set }
    var isDisabled: Bool { get }
}

extension VatoSegmentChildProtocol {
    var isDisabled: Bool {
        return false
    }
}

final class VatoSegmentView<V, D>: UIView, UpdateDisplayProtocol, Weakifiable where V: VatoSegmentChildProtocol, D: Equatable {
    /// Class's public properties.
    typealias SegmentCustomize = (_ idx: Int, _ model: D) -> V
    private let customize: SegmentCustomize
    private let spacing: CGFloat
    private let edges: UIEdgeInsets
    private let axis: NSLayoutConstraint.Axis
    private (set) var source: [D] = []
    private var stackView: UIStackView?
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: nil, action: nil)
        self.addGestureRecognizer(gesture)
        return gesture
    }()
    @Replay(queue: MainScheduler.asyncInstance) private var mCurrentRectSelect: CGRect?
    var currentRectSelect: Observable<CGRect> {
        return $mCurrentRectSelect.filterNil()
    }
    
    weak var scrollView: UIScrollView? {
        didSet {
            setupGesture()
        }
    }
    
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: MainScheduler.asyncInstance) private var _selected: D?
    var selected: Observable<D> {
        return $_selected.filterNil()
    }
    
    init(edges: UIEdgeInsets, spacing: CGFloat, axis: NSLayoutConstraint.Axis, scrollView: UIScrollView? = nil, customize: @escaping SegmentCustomize) {
        self.edges = edges
        self.customize = customize
        self.axis = axis
        self.spacing = spacing
        super.init(frame: .zero)
        self.scrollView = scrollView
        setupGesture()
        setupRX()
    }
    
    private func setupGesture() {
        guard let scrollView = scrollView else { return }
        tapGesture.require(toFail: scrollView.panGestureRecognizer)
    }
    
    private func setupRX() {
        tapGesture.rx.event.bind(onNext: weakify({ (g, wSelf) in
            let p = g.location(in: wSelf)
            wSelf.setSelect(p)
        })).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSelect(_ point: CGPoint) {
        let views = stackView?.arrangedSubviews ?? []
        FindView: for v in views {
            let rect = v.convert(v.bounds, to: self)
            guard rect.contains(point) else {
                continue
            }
            select(at: v.tag)
            break FindView
        }
    }
    
    func select(at idx: Int?) {
        let views = stackView?.arrangedSubviews.compactMap { $0 as? V }
        guard let idx = idx else {
            views?.forEach { $0.isSelected = false }
            return
        }
        if views?[safe: idx]?.isDisabled == true {
            return
        }
        
        views?.enumerated().forEach({ (i) in
            i.element.isSelected = i.offset == idx
            guard i.element.isSelected else { return }
            let r = i.element.bounds
            let rect = i.element.convert(r, to: self)
            mCurrentRectSelect = rect
        })
        _selected = source[safe: idx]
    }
    
    /// Class's private properties.
    func setupDisplay(item: [D]?) {
        let subViews = self.subviews
        if !subViews.isEmpty {
            subViews.forEach { $0.removeFromSuperview() }
        }
    
        guard let item = item, !item.isEmpty else {
            return
        }
        self.source = item
        let views = item.enumerated().map(customize)
        views.enumerated().forEach {
            $0.element.tag = $0.offset
        }
        let stackView = UIStackView(arrangedSubviews: views)
        self.stackView = stackView
        stackView >>> self >>> {
            $0.spacing = spacing
            $0.axis = axis
            $0.distribution = .fill
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(edges)
            }
        }
    }
}
