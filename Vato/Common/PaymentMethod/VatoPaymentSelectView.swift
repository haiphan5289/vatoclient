//  File name   : VatoPaymentSelectView.swift
//
//  Author      : Dung Vu
//  Created date: 7/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import RxSwift
import RxCocoa
import SnapKit

// MARK: -- Manage Data
fileprivate class VatoPaymentMethodDisplay: Weakifiable {
    @VariableReplay var sourceValid: [PaymentCardGroup] = []
    @VariableReplay var sourceDisplay: [PaymentCardDetail] = []
    @VariableReplay var sourceInvalid: [PaymentCardDetail] = []
    private lazy var disposeBag = DisposeBag()
    weak var segment: VatoSegmentView<VatoPaymentSelectItem, PaymentCardDetail>? {
        didSet {
            setupRX()
        }
    }
    @Replay(queue: MainScheduler.asyncInstance) var existData: Bool
    private (set) var canSelect: Bool = false
    
    func swapToDisplay(item: PaymentCardDetail, idx: Int) {
        $sourceValid.take(1).map { (list) -> [PaymentCardGroup] in
            list[safe: idx]?.first = item
            return list
        }.bind(onNext: weakify({ (items, wSelf) in
            wSelf.sourceDisplay = items.compactMap(\.first)
        })).disposed(by: disposeBag)
    }
    
    func updateSource(items valid: [PaymentCardGroup], invalid: [PaymentCardGroup]? = nil) {
        canSelect = valid.reduce(false, { $0 || $1.first?.canUse == true })
        sourceValid = valid
        sourceDisplay = valid.compactMap(\.first)
        sourceInvalid = invalid?.flatMap(\.list) ?? []
    }
    
    private func setupRX() {
        Observable.combineLatest($sourceDisplay, $sourceInvalid).bind(onNext: weakify({ (items, wSelf) in
            wSelf.segment?.setupDisplay(item: items.0 + items.1)
            let i = items.0.count + items.1.count
            wSelf.existData = i > 0
        })).disposed(by: disposeBag)
    }
}

// MARK: -- MainView
final class VatoPaymentSelectView: UIView, Weakifiable {
    @IBOutlet var lblTitle1: UILabel?
    @IBOutlet var lblTitle2: UILabel?
    
    @IBOutlet var scrollView1: UIScrollView?
    @IBOutlet var scrollView2: UIScrollView?
    
    @IBOutlet var container1: UIView?
    @IBOutlet var container2: UIView?
    
    private var paymentStream: PaymentStream? {
        didSet {
            setupRX()
        }
    }
    
    private var source1: VatoPaymentMethodDisplay = VatoPaymentMethodDisplay()
    private var source2: VatoPaymentMethodDisplay = VatoPaymentMethodDisplay()
    
    @Replay(queue: MainScheduler.asyncInstance) private var mSelected: PaymentCardDetail
    @Replay(queue: MainScheduler.asyncInstance)  private var beforeSelected: PaymentCardDetail?
    
    var selected: Observable<PaymentCardDetail> {
        return $mSelected
    }
    @Published private var mUpdateLayout: CGFloat
    var updateLayout: Observable<CGFloat> {
        return $mUpdateLayout.distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    var loadDefaultMethod: Bool = true
    private lazy var disposeBag = DisposeBag()
    private var type: SwitchPaymentType = .all
    private var disposeLoadMethod: Disposable?
    private var disposeLoadDefaultMethod: Disposable?
    private var disposeSelect: Disposable?
    private var disposeListenAddCard: Disposable?
    weak var controller: UIViewController?
    
    static func createPaymentView(use paymentStream: PaymentStream, service: SwitchPaymentType) -> VatoPaymentSelectView {
        let new = VatoPaymentSelectView.loadXib()
        new.beforeSelected = nil
        new.paymentStream = paymentStream
        new.type = service
        return new
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
        guard loadDefaultMethod else {
            return
        }
        loadDefault()
    }
    
    private func updateListCard(list: [PaymentCardDetail]) {
        var next = list
        let cash = PaymentCardDetail.cash()
        let vatopay = PaymentCardDetail.vatoPay()
        next.insert(vatopay, at: 0)
        next.insert(cash, at: 0)
        
        let atm = PaymentCardDetail.atm()
        let credit = PaymentCardDetail.credit()
        let momo = PaymentCardDetail.momo()
        let zalopay = PaymentCardDetail.zaloPay()
        
        next += [atm, credit, momo, zalopay]
        let result = FireStoreConfigDataManager.shared.filterSource(from: next, type: type)
        var s1 = result.s1
        let canAddCard = FireStoreConfigDataManager.shared.canAddCard(type: type)
        // Add Card
        if canAddCard.visa && list.first(where: { PaymentCardType.visa...PaymentCardType.master ~= $0.type }) == nil {
            let listAddCard = PaymentCardGroup()
            let addCard = PaymentCardDetail.addCardVisaMaster()
            listAddCard.list.append(addCard)
            listAddCard.first = addCard
            s1.append(listAddCard)
        }
        
        if canAddCard.atm && list.first(where: { $0.type == .atm }) == nil {
            let listAddCardATM = PaymentCardGroup()
            let addCardATM = PaymentCardDetail.addCardATM()
            listAddCardATM.list.append(addCardATM)
            listAddCardATM.first = addCardATM
            
            s1.append(listAddCardATM)
        }
        
        source1.updateSource(items: s1)
        source2.updateSource(items: result.s2, invalid: result.s3)
    }
    
    private func bindingSource() {
        guard let paymentStream = paymentStream else {
            return assert(false, "Check code")
        }
        disposeLoadMethod?.dispose()
        disposeLoadMethod = paymentStream.source.distinctUntilChanged().bind(onNext: weakify({ (list, wSelf) in
            wSelf.updateListCard(list: list)
        }))
    }
    
    private func calculateHeight(valid: Bool) {
        let s: CGSize
        if valid {
            s = self.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        } else {
            s = .zero
        }
        let constant = s.height.isInfinite ? 0 : s.height
        mUpdateLayout = constant
    }
    
    private func setupRX() {
        bindingSource()
        source1.segment?.selected.bind(onNext: weakify({ (card, wSelf) in
            wSelf.source2.segment?.select(at: nil)
            wSelf.mSelected = card
        })).disposed(by: disposeBag)
        
        source2.segment?.selected.bind(onNext: weakify({ (card, wSelf) in
            wSelf.source1.segment?.select(at: nil)
            wSelf.mSelected = card
        })).disposed(by: disposeBag)
        
        Observable.combineLatest(source1.$existData, source2.$existData).bind(onNext: weakify({ (item, wSelf) in
            wSelf.container1?.isHidden = !item.0
            wSelf.container2?.isHidden = !item.1
            wSelf.calculateHeight(valid: item.0 || item.1)
        })).disposed(by: disposeBag)
    }
    
    private func trySelect(from source: VatoPaymentMethodDisplay) {
        source.$sourceValid.take(1).bind { [weak source] (list) in
            guard let idx = list.firstIndex(where: { $0.first?.canUse == true && $0.first?.addCard == false }) else {
                source?.segment?.select(at: nil)
                return
            }
            source?.segment?.select(at: idx)
        }.disposed(by: disposeBag)
    }
    
    private func loadDefault() {
        disposeLoadDefaultMethod?.dispose()
        disposeLoadDefaultMethod = Observable.combineLatest(source1.$existData, source2.$existData)
            .filter { $0 || $1 }
            .take(1)
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: weakify({ (_, wSelf) in
            if wSelf.source1.canSelect {
                wSelf.trySelect(from: wSelf.source1)
                wSelf.scrollSelect(event: wSelf.source1.segment?.currentRectSelect, scrollView: wSelf.scrollView1)
                return
            }
            
            if wSelf.source2.canSelect {
                wSelf.trySelect(from: wSelf.source2)
                wSelf.scrollSelect(event: wSelf.source2.segment?.currentRectSelect, scrollView: wSelf.scrollView2)
            }
        }))
    }
    
    private func visualize() {
        lblTitle1?.text = FwiLocale.localized("Phương thức thanh toán")
        lblTitle2?.text = FwiLocale.localized("Phương thức thanh toán khác")
        
        let segment1 = VatoSegmentView<VatoPaymentSelectItem, PaymentCardDetail>.init(edges: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), spacing: 8, axis: .horizontal) { [weak self](idx, item) -> VatoPaymentSelectItem in
            let v = VatoPaymentSelectItem.loadXib()
            v.setupDisplay(item: item)
            let s = self?.source1.sourceValid[safe: idx]?.list
            let i = s?.count ?? 0
            let hidden = !(i > 1)
            v.btnMoreView?.isHidden = hidden && !item.addCard
            v.iconMore?.isHidden = hidden
            self?.addHandlerChangeMethod(v: v, index: 1, selectIdx: idx)
            return v
        }
        scrollView1?.showsHorizontalScrollIndicator = false
        segment1 >>> scrollView1 >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(24)
            }
        }
        segment1.scrollView = scrollView1
        source1.segment = segment1
        
        let segment2 = VatoSegmentView<VatoPaymentSelectItem, PaymentCardDetail>.init(edges: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), spacing: 8, axis: .horizontal) { [weak self](idx, item) -> VatoPaymentSelectItem in
            let v = VatoPaymentSelectItem.loadXib()
            v.setupDisplay(item: item)
            let s = self?.source2.sourceValid[safe: idx]?.list
            let i = s?.count ?? 0
            let hidden = !(i > 1)
            v.btnMoreView?.isHidden = hidden && !item.addCard
            v.iconMore?.isHidden = hidden
            self?.addHandlerChangeMethod(v: v, index: 2, selectIdx: idx)
            return v
        }
        
        scrollView2?.showsHorizontalScrollIndicator = false
        segment2 >>> scrollView2 >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(24)
            }
        }
        segment2.scrollView = scrollView2
        source2.segment = segment2
    }
}

// MARK: -- Choose other method
extension VatoPaymentSelectView {
    private func showChoose(index: Int, selectIdx: Int) {
        let manager: VatoPaymentMethodDisplay = index == 1 ? source1 : source2
        if let item = manager.sourceValid[safe: selectIdx]?.first, item.addCard  {
            mSelected = item
            listenAddCard()
            return
        }
        
        let original = manager.$sourceValid
        let source = original.map { (list) -> [PaymentCardDetail] in
            return list[safe: selectIdx]?.list ?? []
        }
        guard let e1 = manager.segment?.selected else { return }
        VatoPaymentSelectOrtherVC.showUse(source: source, on: controller,
                                          currentSelect: e1, heightCell: 72,
                                          title: FwiLocale.localized("Phương thức thanh toán khác"))
            .filterNil()
            .bind(onNext: weakify({ [weak manager] (card, wSelf) in
            manager?.swapToDisplay(item: card, idx: selectIdx)
            manager?.segment?.select(at: selectIdx)
        })).disposed(by: disposeBag)
    }
    
    private func addHandlerChangeMethod(v: VatoPaymentSelectItem, index: Int, selectIdx: Int) {
        v.btnMoreView?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.showChoose(index: index, selectIdx: selectIdx)
        })).disposed(by: disposeBag)
    }
}


// MARK: -- Reload data
extension VatoPaymentSelectView {
    func reload(service: SwitchPaymentType) {
        self.type = service
        source1.existData = false
        source2.existData = false
        bindingSource()
        loadDefault()
    }
}

// MARK: -- Select card
extension VatoPaymentSelectView {
    private func find(card: PaymentCardDetail, in source: VatoPaymentMethodDisplay) -> Int? {
        // Finding can select default
        if let idx = source.sourceDisplay.firstIndex(of: card) {
            return idx
        }
        
        // Finding group
        if let idx = source.sourceValid.firstIndex(where: { $0.contain(card: card) }) {
            source.swapToDisplay(item: card, idx: idx)
            return idx
        }
        
        return nil
    }
    
    private func listenAddCard() {
        disposeListenAddCard?.dispose()
        guard let paymentStream = paymentStream else {
            return
        }
    
        let e1 = paymentStream.changedSource.distinctUntilChanged()
        let e2 = paymentStream.newCard.skip(1).distinctUntilChanged()
        let e3 = paymentStream.source.distinctUntilChanged()
        
        disposeListenAddCard = Observable.combineLatest(e1, e2, e3, resultSelector: { ($0, $1, $2) }).bind(onNext: weakify({ (result, wSelf) in
            if let new = result.1 {
                wSelf.select(card: new)
                return
            }
            
            if !result.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard let current = wSelf.paymentStream?.currentSelect else {
                         wSelf.select(card: nil)
                        return
                    }
                    if result.2.contains(current) {
                        wSelf.select(card: current)
                    } else {
                        wSelf.select(card: current.localPayment ? current : nil)
                    }
                }
            }
        }))
    }
    
    func resetListenAddCard() {
        disposeListenAddCard?.dispose()
    }
    
    private func scrollSelect(event: Observable<CGRect>?, scrollView: UIScrollView?) {
        event?.take(1).bind(onNext: { [weak scrollView] (rect) in
            scrollView?.scrollRectToVisible(rect, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func findingIndexSelect(card: PaymentCardDetail?) {
        guard let card = card else {
            return loadDefault()
        }
        
        if let idx = find(card: card, in: source1) {
            source1.segment?.select(at: idx)
            scrollSelect(event: source1.segment?.currentRectSelect, scrollView: scrollView1)
            return
        }
        
        if let idx = find(card: card, in: source2) {
            source2.segment?.select(at: idx)
            scrollSelect(event: source2.segment?.currentRectSelect, scrollView: scrollView2)
            return
        }
        loadDefault()
    }
    
    func select(card: PaymentCardDetail?) {
        disposeSelect?.dispose()
        disposeSelect = Observable.combineLatest(source1.$existData, source2.$existData)
            .filter { $0 || $1 }
            .take(1)
            .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: weakify({ (_, wSelf) in
            wSelf.findingIndexSelect(card: card)
        }))
    }
}

