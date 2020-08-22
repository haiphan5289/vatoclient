
//
//  CheckOutBookingView.swift
//  Vato
//
//  Created by khoi tran on 12/12/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import SnapKit
import FwiCoreRX

final class CheckOutBookingView: UIView, UpdateDisplayProtocol {
    
    @IBOutlet weak var paymentMethodBg: UIView?
    @IBOutlet weak var paymentMethodLabel: UILabel?
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var btnChoosePaymentMethod: UIButton?
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailPriceButton: UIButton!
    @IBOutlet weak var lblChoosePaymentMethod: UILabel!
    @IBOutlet weak var containerPrice: UIView?
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var hPromotionView: NSLayoutConstraint?
    @IBOutlet weak var containerPayment: UIView?
    @IBOutlet weak var hContainerPayment: NSLayoutConstraint?
    
    @IBOutlet weak var btnExpandPrice: UIButton?
    @IBOutlet weak var hContainerPrice: NSLayoutConstraint?
    
    private var detailPriceView: DetailPriceView = DetailPriceView(frame: .zero)
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 8)
        v.containerColor = .white
        return v
    }()
    
    private (set) lazy var disposeBag = DisposeBag()
    
    private(set) lazy var eAction: PublishSubject<BookingConfirmType> = PublishSubject()
    private(set) lazy var eUpdate: PublishSubject<BookingConfirmUpdateType> = PublishSubject()
    var itemsView: [BookingConfirmItemView]? {
        return self.stackView?.arrangedSubviews.compactMap({ $0 as? BookingConfirmItemView })
    }
    private lazy var mApplyPromotion = PublishSubject<EcomPromotionDisplay>()
    var applyPromotion: Observable<EcomPromotionDisplay> {
        return mApplyPromotion
    }
    
    func updateListPromotions(list: [EcomPromotionDisplay]) {
        guard !list.isEmpty, let collectionView = collectionView else { return }
        hPromotionView?.constant = 70
        Observable.just(list)
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items(cellIdentifier: CheckOutPromotionCVC.identifier, cellType: CheckOutPromotionCVC.self))
        { [unowned self] idx, element, cell in
            self.setupDisplay(for: cell, item: element)
        }.disposed(by: disposeBag)
    }
    
    private func setupDisplay(for cell: CheckOutPromotionCVC, item: EcomPromotionDisplay) {
        cell.setupDisplay(item: item)
        cell.btnSelect?.rx.tap.takeUntil(cell.rx.methodInvoked(#selector(CheckOutPromotionCVC.prepareForReuse))).bind(onNext: { [weak self] (_) in
            self?.mApplyPromotion.onNext(item)
        }).disposed(by: disposeBag)
    }
}


extension CheckOutBookingView: Weakifiable {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        visualize()
        setupRX()
    }
    
    private func setupRX() {
        btnExpandPrice?.rx.tap.debounce(.milliseconds(200), scheduler: MainScheduler.instance).scan(false, accumulator: { (old, _) -> Bool in
            return !old
        }).distinctUntilChanged().bind(onNext: weakify({ (v, wSelf) in
            let h: CGFloat
            if !v {
                h = 0
            } else {
                let s = wSelf.detailPriceView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                h = s.height.isInfinite ? 0 : s.height
            }
            UIView.animate(withDuration: 0.3) {
                wSelf.hContainerPrice?.constant = h
            }
        })).disposed(by: disposeBag)
        
        eUpdate.bind { [weak self] type in
            guard let wSelf = self else {
                return
            }
            
            switch type {
            case .note(let string):
                let f = wSelf.itemsView?.first(where: { $0.type == .note })
                f?.update(from: BookingConfirmUpdateType.update(string: nil, exist: string?.isEmpty == false))
            case .updateMethod(let method):
                wSelf.paymentMethodBg?.backgroundColor = method.bgColor
                wSelf.paymentMethodLabel?.text = method.nameDisplay
            default:
                break
            }
        }.disposed(by: disposeBag)
        
        let wallet = self.btnChoosePaymentMethod?.rx.tap.map { BookingConfirmType.wallet }
        let next =  self.continueButton.rx.tap.map { BookingConfirmType.booking }
        let detailPrice = self.detailPriceButton.rx.tap.map { BookingConfirmType.detailPrice }
        Observable.merge([wallet, next, detailPrice].compactMap { $0 }).subscribe(eAction).disposed(by: disposeBag)
    }
    
    private func initialize() {
        updatelayout()
    }
    
    private func visualize() {
        discountPriceLabel?.text = FwiLocale.localized("Chi tiết giá")
        collectionView?.register(CheckOutPromotionCVC.loadNib(), forCellWithReuseIdentifier: CheckOutPromotionCVC.identifier)
        containerView.backgroundColor = .clear
        containerView.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        continueButton.isEnabled = true
        continueButton.setTitle(Text.confirmOrder.localizedText, for: .normal)
        continueButton.setTitle(Text.confirmOrder.localizedText, for: .disabled)
        
        lblChoosePaymentMethod.text = Text.choosePaymentMethod.localizedText
        
        detailPriceView >>> containerPrice >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
        }
    }
    
    func updatelayout() {
        let source = BookingConfirmType.allCases
        
        let items = source.map({ type -> BookingConfirmItemView in
            let v = BookingConfirmItemView.createView(with: type)
            v.btnAction?.rx.tap.map { type }.subscribe(onNext: { [weak self] in
                self?.eAction.onNext($0)
            }).disposed(by: disposeBag)
            return v
        })
        
        items.last?.lineLeftView?.isHidden = true
        items.enumerated().forEach { e in
            self.stackView?.insertArrangedSubview(e.element, at: e.offset)
        }
    }
}

extension CheckOutBookingView {
    func setupDisplay(item: QuoteCart?) {
        guard let quoteCart = item else {
            return
        }
        let discountPrice = quoteCart.grandTotal ?? 0
        finalPriceLabel.text = discountPrice.currency
        discountPriceLabel.text = "" //price.currency
        let i = itemsView?.first(where: { $0.type == .coupon })
        if let tPromotion = item?.nameRuleDiscount, !tPromotion.isEmpty  {
            i?.update(from: .update(string: tPromotion, exist: true))
            i?.iconStatus?.isHighlighted = true
        } else {
            i?.update(from: .update(string: nil, exist: false))
        }
    }
}
        
