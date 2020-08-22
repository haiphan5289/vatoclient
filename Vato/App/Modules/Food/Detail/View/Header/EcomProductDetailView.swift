//  File name   : EcomProductDetailView.swift
//
//  Author      : Dung Vu
//  Created date: 7/7/20
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
import Atributika
import GSKStretchyHeaderView

// MARK: -- Item
final class EcomPromotionItemView: UIView, UpdateDisplayProtocol, VatoSegmentChildProtocol {
    private lazy var bgView = UIImageView(image: UIImage(named: "bg_food_promotion"))
    private lazy var iconPromotionView = UIImageView(image: UIImage(named: "ic_food_discount"))
    private lazy var lblDescription = UILabel(frame: .zero)
    var isSelected: Bool = false
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else { return }
        visualize()
    }
    
    private func visualize() {
        bgView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        iconPromotionView >>> {
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        
        lblDescription >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        let stackView = UIStackView(arrangedSubviews: [iconPromotionView, lblDescription])
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 8
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(9)
                make.right.equalTo(-9)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: EcomPromotion?) {
        lblDescription.text = item?.name
    }
}

enum EcomPromotionDisplayType {
    case compact
    case full
    
    var next: EcomPromotionDisplayType {
        switch self {
        case .compact:
            return .full
        case .full:
            return .compact
        }
    }
    
    func text(from numberItems: Int) -> String {
        switch self {
        case .full:
            return FwiLocale.localized("Thu gọn")
        case .compact:
            let result = String(format: FwiLocale.localized("Xem thêm %d khuyến mãi"), numberItems)
            return result
        }
    }
}

final class EcomPromotionListView: UIView, UpdateDisplayProtocol, Weakifiable {
    private (set) var segmentView: VatoSegmentView<EcomPromotionItemView, EcomPromotion>?
    private var stackView: UIStackView?
    @VariableReplay private var source: [EcomPromotion] = []
    private lazy var disposeBag = DisposeBag()
    private var _eventLayout: PublishSubject<Void> = PublishSubject()
    private var lblTitle: UILabel?
    private var currentType: EcomPromotionDisplayType = .compact
    var eventLayout: Observable<Void> {
        return _eventLayout
    }
    private var bottom: CGFloat = 16
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay(item: [EcomPromotion]?) {
        self.source = item ?? []
        self.isHidden = self.source.isEmpty
        guard !isHidden else {
            return
        }
        lblTitle?.isHidden = false
        if source.count > 2 {
            bottom = 43
            stackView?.snp.updateConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.bottom.equalTo(-43).priority(.high)
                make.right.equalTo(-16).priority(.high)
            })
            let btnExpand = UIButton(frame: .zero)
            btnExpand >>> self >>> {
                $0.setTitleColor(Color.orange, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                $0.snp.makeConstraints { (make) in
                    make.left.equalTo(112)
                    make.bottom.equalTo(-10)
                }
            }
            setupHandlerExpand(button: btnExpand)
        } else {
            bottom = 16
            segmentView?.setupDisplay(item: item)
            _eventLayout.onNext(())
        }
    }
    
    private func setupHandlerExpand(button: UIButton) {
        let e1 = button.rx.tap.scan(.compact) { (old, _) -> EcomPromotionDisplayType in
            return old.next
        }.startWith(.compact)
        let e2 = $source
        
        Observable.combineLatest(e1, e2) { [weak self](type, source) -> (String, [EcomPromotion]) in
            let next: [EcomPromotion]
            let text: String
            switch type {
            case .compact:
                next = Array(source.prefix(2))
            case .full:
                next = source
            }
            self?.currentType = type
            text = type.text(from: source.count - next.count)
            return (text, next)
        }.bind(onNext: weakify({ [weak button](item, wSelf) in
            wSelf.segmentView?.setupDisplay(item: item.1)
            button?.setTitle(item.0, for: .normal)
            wSelf._eventLayout.onNext(())
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        clipsToBounds = true
        self.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), position: .top)
        let segmentView = VatoSegmentView<EcomPromotionItemView, EcomPromotion>.init(edges: .zero, spacing: 8, axis: .vertical) { (idx, item) -> EcomPromotionItemView in
            let view = EcomPromotionItemView(frame: .zero)
            view.setupDisplay(item: item)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(32)
            }
            return view
        }
        
        self.segmentView = segmentView
        
        let containerText = UIView(frame: .zero)
        containerText.backgroundColor = .white
        containerText.setContentHuggingPriority(.required, for: .horizontal)
        let label = UILabel(frame: .zero)
        label >>> containerText >>> {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = FwiLocale.localized("Khuyến mãi")
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
        }
        lblTitle = label
        
        let stackView = UIStackView(arrangedSubviews: [containerText, segmentView])
        stackView >>> self >>> {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 10
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.bottom.equalTo(-16).priority(.high)
                make.right.equalTo(-16).priority(.high)
            }
        }
        self.stackView = stackView
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        if source.isEmpty {
            return .zero
        } else {
            let items: CGFloat = CGFloat(self.segmentView?.source.count ?? 0)
            guard items > 0 else {
                return .zero
            }
            var h = items * 32 + (items - 1) * 5 + bottom
            if currentType == .compact {
                h -= 20
            }
            return CGSize(width: targetSize.width, height: h)
        }
    }
}


// MARK: -- Main
final class EcomProductDetailHeaderView: UIView, UpdateDisplayProtocol, DisplayDistanceProtocol, DisplayPromotionProtocol {
    /// Class's public properties.
    struct Configs {
        static let hBanner: CGFloat = 200
    }
    
    private var iconAuthView: UIImageView?
    private var lblDescription: UILabel?
    
    var lblDistance: UILabel? { return nil }
    var lblTime: UILabel? { return nil }
    var lblDiscount: UILabel? { return nil }
    var viewDiscount: UIStackView? { return nil }
    
    private var lblInfoStore: UILabel?
    private var lblStoreName: UILabel?
    private var lblStoreDescription: UILabel?
    
    private lazy var containerTopView = UIView(frame: .zero)
    private lazy var bannerView = UIView(frame: .zero)
    private (set) lazy var titleView: UIView = UIView(frame: .zero)
    private (set) lazy var lblTitle = UILabel(frame: .zero)
    private var scrollView: VatoScrollView<VatoBannerView<String>>?
    private (set) lazy var selectCategoryView = StoreSelectCategoryView(frame: .zero)
    private (set) var listPromotionView: EcomPromotionListView?
    private (set) var imagePromotionView: UIImageView?
    
    private lazy var disposeBag = DisposeBag()
    private var _eventLayout: PublishSubject<Void> = PublishSubject()
    private (set) var btnShowMap: UIButton?
    private (set) var btnShare: UIButton?
    var eventLayout: Observable<Void> {
        return _eventLayout
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Class's private properties.
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else { return }
    }
    
    func setupDisplay(item: FoodExploreItem?) {
        scrollView?.setupDisplay(item: item?.bannerImage)
        
        iconAuthView?.isHidden = item?.infoStoreVerify == nil
        iconAuthView?.setImage(from: item?.infoStoreVerify, placeholder: nil, size: CGSize(width: 24, height: 24))
        
        lblDescription?.text = item?.infoStoreVerify?.label
        lblDescription?.textColor = item?.infoStoreVerify?.color
        
        lblStoreName?.text = item?.name
        lblStoreDescription?.text = item?.descriptionCat
        displayPromotion(item: item?.storeProductDiscountInformation)
        guard let today = FoodWeekDayType.today() else { return }
        var text: String
        let color: UIColor
        if let time = item?.workingHours?.daily?[today] {
            text = "<b>\(time.openText)</b>"
            color = time.color
        } else {
            text = "<b>--</b>"
            color = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        if let closeString = item?.workingHours?.getCloseTime(), !closeString.isEmpty {
            text = "\(text) <i>(đến \(closeString))</i>"
        }
        
        let b = Atributika.Style("b").foregroundColor(color)
        let i = Atributika.Style("i").foregroundColor(Color.battleshipGrey)
        let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)).font(UIFont.systemFont(ofSize: 14, weight: .regular))
        let result = getTextDistance(item: item)
        let new = "\(result.distance) • \(result.time) • \(text)"
        lblInfoStore?.attributedText = new.style(tags: b, i).styleAll(all).attributedString
    }
    
    func updateListSelect(items: [StoreCategoryDisplayProtocol]?) {
        let show = items?.isEmpty == false
        selectCategoryView.setupDisplay(item: items)
        guard show else { return }
        selectCategoryView.snp.updateConstraints { (make) in
            make.height.equalTo(48)
        }
        _eventLayout.onNext(())
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        var h: CGFloat = 394
        let edges = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        if edges.top == 20 {
            h -= 24
        }
        
        if let s = self.listPromotionView?.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority) {
            h += s.height
        }
        
        let size = CGSize(width: targetSize.width, height: h)
        if selectCategoryView.source.isEmpty {
            return size
        } else {
            return CGSize(width: size.width, height: size.height + 58)
        }
    }
}

// MARK: Class's public methods
extension EcomProductDetailHeaderView {
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: Class's private methods
private extension EcomProductDetailHeaderView {
    private func visualize() {
        // todo: Visualize view's here.
        self.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let edges = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        let h = Configs.hBanner + edges.top
        
        // MARK: -- Banner
        containerTopView.backgroundColor = .white
        bannerView >>> containerTopView >>> {
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.top.lessThanOrEqualTo(0)
                make.left.right.equalToSuperview()
                make.height.equalTo(h)
            }
        }
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: h))
        let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.frame = rect
        shape.fillColor = UIColor.blue.cgColor
        shape.path = benzier.cgPath
        bannerView.layer.mask = shape
        
        let scrollView = VatoScrollView<VatoBannerView<String>>.init(edge: .zero, sizeItem: CGSize(width: UIScreen.main.bounds.width, height: h), spacing: 0, type: .banner)
        scrollView >>> bannerView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(h)
            }
        }
        self.scrollView = scrollView
        
        let imagePromotionView = UIImageView(frame: .zero)
        self.imagePromotionView = imagePromotionView
        
        imagePromotionView >>> containerTopView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.bottom.equalTo(bannerView.snp.bottom).offset(-16)
                make.size.equalTo(CGSize(width: 74, height: 20))
            }
        }
        
        let btnShowMap: UIButton = UIButton(frame: .zero)
        self.btnShowMap = btnShowMap
        btnShowMap >>> containerTopView >>> {
            $0.backgroundColor = .white
            $0.tintColor = Color.orange
            $0.setImage(UIImage(named: "ic_information_merchant")?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalTo(bannerView.snp.bottom)
                make.size.equalTo(CGSize(width: 32, height: 32))
            }
        }
        
        // icShare
        let btnShare: UIButton = UIButton(frame: .zero)
        self.btnShare = btnShare
        btnShare >>> containerTopView >>> {
            $0.backgroundColor = .white
            $0.tintColor = Color.orange
            $0.setImage(UIImage(named: "icShare")?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(btnShowMap.snp.left).offset(-16)
                make.centerY.equalTo(bannerView.snp.bottom)
                make.size.equalTo(CGSize(width: 32, height: 32))
            }
        }
        
        // MARK: -- Title view
        let statusH: CGFloat
        if #available(iOS 12.0, *) {
            statusH = 0
        } else {
            statusH = UIApplication.shared.statusBarFrame.height
        }
        
        let hTitle = edges.top + 44 + statusH
        titleView >>> self >>> {
            $0.backgroundColor = .white
            $0.alpha = 0
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(hTitle)
            })
        }
        
        lblTitle >>> titleView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-10)
                make.width.lessThanOrEqualTo(250)
            })
        }
        
        // MARK: -- Store verify
        let lblDescription = UILabel(frame: .zero)
        lblDescription >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        let iconView = UIImageView(frame: .zero)
        iconView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblDescription, iconView])
        stackView >>> containerTopView >>> {
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 5
            
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(bannerView.snp.bottom).offset(15)
            }
        }
        self.iconAuthView = iconView
        self.lblDescription = lblDescription
        
        // MARK: -- Store Info
        let lblStoreName = UILabel(frame: .zero)
        self.lblStoreName = lblStoreName
        let lblStoreDescription = UILabel(frame: .zero)
        self.lblStoreDescription = lblStoreDescription
        let lblInfoStore = UILabel(frame: .zero)
        self.lblInfoStore = lblInfoStore
        
        lblStoreName >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        lblStoreDescription >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        
        lblInfoStore >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        let stackView2 = UIStackView(arrangedSubviews: [lblStoreName, lblStoreDescription, lblInfoStore])
        stackView2 >>> containerTopView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 8
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16).priority(.high)
                make.top.equalTo(bannerView.snp.bottom).offset(30)
            }
        }
        
        // MARK: -- Promotion
        let listPromotionView = EcomPromotionListView(frame: .zero)
        listPromotionView >>> containerTopView >>> {
            $0.isHidden = true
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(stackView2.snp.bottom).offset(16).priority(.high)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()//.priority(.high)
            }
        }
        self.listPromotionView = listPromotionView
        listPromotionView.eventLayout.bind(onNext: { [weak self] in
            self?._eventLayout.onNext(())
        }).disposed(by: disposeBag)
        
        containerTopView.addSeperator()
        containerTopView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
            }
        }
        
        selectCategoryView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(containerTopView.snp.bottom).offset(9)
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
        }
        
        selectCategoryView.addSeperator(position: .top)
        self.bringSubviewToFront(titleView)
    }
}

// MARK: -- Header Table View
final class EcomProductTableHeaderView: GSKStretchyHeaderView {
    private (set) lazy var view = EcomProductDetailHeaderView(frame: .zero)
    var titleView: UIView {
        return view.titleView
    }
    
    var selectCategoryView: StoreSelectCategoryView {
        return view.selectCategoryView
    }
    
    var lblTitle: UILabel {
        return view.lblTitle
    }
    
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        contentView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        let statusH: CGFloat
        if #available(iOS 12.0, *) {
            statusH = 0
        } else {
            statusH = UIApplication.shared.statusBarFrame.height
        }
        minimumContentHeight = edge.top + 92 + statusH
        view >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        // 0.3 -> 1
        let nexAlpha: CGFloat
        switch stretchFactor {
        case ...0.65:
            nexAlpha = 1 - stretchFactor / 0.65
            UIApplication.setStatusBar(using: .default)
        default:
            nexAlpha = 0
            UIApplication.setStatusBar(using: .lightContent)
        }
        titleView.alpha = nexAlpha
    }
}
