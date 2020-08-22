//  File name   : VatoPromotionNewsCell.swift
//
//  Author      : Dung Vu
//  Created date: 6/2/20
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
import Eureka
import VatoNetwork

protocol StaticConfigDisplayHomeItemProtocol {
    static var sizeItem: CGSize { get }
    static var spacingItem: CGFloat { get }
    static var containerInset: UIEdgeInsets { get }
    static var contentSectionInset: UIEdgeInsets { get }
    static var typeScroll: VatoScrollViewType { get }
}

protocol LoadDummyProtocol {
    func loadDummyView()
    func stopLoadDummyView()
}

// MARK: - Layout Item
class VatoMainItemLayout1: UIView, UpdateDisplayProtocol, LoadDummyProtocol, HandlerEventReuseProtocol, StaticConfigDisplayHomeItemProtocol {
    class var sizeItem: CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 32, height: 224)
    }
    
    class var spacingItem: CGFloat {
        return 0
    }
    
    class var contentSectionInset: UIEdgeInsets {
        return .zero
    }
    
    class var typeScroll: VatoScrollViewType {
        return .carousel
    }
    
    static var containerInset: UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    var reuseEvent: Observable<Void>?
    private (set) lazy var imgView = UIImageView(frame: .zero)
    private (set) lazy var lblTitle = UILabel(frame: .zero)
    private (set) lazy var lblDistance = UILabel(frame: .zero)
    private (set) lazy var lblSubTitle = UILabel(frame: .zero)
    private lazy var disposeBag = DisposeBag()
    internal lazy var containerView = UIView(frame: .zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        containerView >>> self >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(52)
            }
        }
        
        lblTitle >>> {
            $0.text = "dada"
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        lblDistance >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        let s1 = UIStackView(arrangedSubviews: [lblTitle, lblDistance])
        s1 >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 3
        }
        
        lblSubTitle >>> {
            $0.text = "dada"
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        
        let stackView = UIStackView(arrangedSubviews: [s1, lblSubTitle])
        stackView >>> containerView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 2
            $0.snp.makeConstraints { (make) in
                
                make.left.equalTo(12)
                make.top.equalTo(7)
                make.right.equalTo(-12)
            }
        }
        
        imgView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(containerView.snp.top).priority(.high)
            }
        }
    }
    
    func stopLoadDummyView() {}
    
    func loadDummyView() {
        LoadingShimmerView.startAnimate(in: imgView)
        LoadingShimmerView.startAnimate(in: lblTitle)
        LoadingShimmerView.startAnimate(in: lblSubTitle)
    }
    
    func setupDisplay(item: VatoHomeLandingItem?) {
        lblTitle.text = item?.title
        lblSubTitle.text = item?.subtitle
        lblDistance.text = item?.action.distance
        let task = imgView.setImage(from: item, placeholder: nil, size: CGSize(width: UIScreen.main.bounds.width, height: 64))
        reuseEvent?.take(1).bind(onNext: { (_) in
            task?.cancel()
        }).disposed(by: disposeBag)
    }
}

final class VatoMainItemLayout2: VatoMainItemLayout1 {
    override class var sizeItem: CGSize {
        return CGSize(width: 238, height: 186)
    }
    
    override class var spacingItem: CGFloat {
       return 16
    }
    
    override class var typeScroll: VatoScrollViewType {
        return .scrollHorizontal
    }
        
    override func visualize() {
        super.visualize()
        lblSubTitle.numberOfLines = 2
        clipsToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        
        containerView.snp.updateConstraints { (make) in
            make.height.equalTo(70)
        }
    }
}

// MARK: - Child View
typealias VatoMainChildViewProtocol = UpdateDisplayProtocol & LoadDummyProtocol & StaticConfigDisplayHomeItemProtocol & HandlerEventReuseProtocol

final class VatoMainLayoutChildView<T: UIView>: UIView, UpdateDisplayProtocol, LoadDummyProtocol where T: VatoMainChildViewProtocol, T.Value: Equatable {
    typealias Value = [T.Value]
    private (set) lazy var lblTitle = UILabel(frame: .zero)
    private (set) lazy var itemsView = VatoScrollView<T>(edge: T.contentSectionInset, sizeItem: T.sizeItem, spacing: T.spacingItem, type: T.typeScroll, bottomPageIndicator: -42)
    private var stackView: UIStackView!
    private var dummyViews = [UIView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        lblTitle >>> {
            $0.text = "abc"
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        itemsView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(T.sizeItem.height + 2)
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, itemsView])
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 16
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(T.containerInset)
            }
        }
        self.stackView = stackView
    }
    
    func loadDummyView() {
        stackView.isHidden = true
        let v = UIView(frame: .zero)
        v >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(lblTitle.snp.left)
                make.right.equalTo(lblTitle.snp.right)
                make.bottom.equalTo(lblTitle.snp.bottom)
                make.top.equalTo(lblTitle.snp.top)
            }
        }
        LoadingShimmerView.startAnimate(in: v)
        dummyViews.append(v)
        let containerInset = T.containerInset
        let size = T.sizeItem
        let spacing = T.spacingItem
        
        let w = size.width + containerInset.left + containerInset.right + spacing
        let view1 = T(frame: .zero)
        dummyViews.append(view1)
        if w < UIScreen.main.bounds.width {
            view1 >>> self >>> {
                $0.loadDummyView()
                $0.snp.makeConstraints { (make) in
                    make.left.equalTo(containerInset.left)
                    make.top.equalTo(lblTitle.snp.bottom).offset(16).priority(.high)
                    make.size.equalTo(size)
                }
            }
            let view2 = T(frame: .zero)
            view2 >>> self >>> {
                $0.loadDummyView()
                $0.snp.makeConstraints { (make) in
                    make.left.equalTo(view1.snp.right).offset(spacing)
                    make.top.equalTo(view1.snp.top).priority(.high)
                    make.size.equalTo(size)
                }
            }
            dummyViews.append(view2)
        } else {
            view1 >>> self >>> {
                $0.loadDummyView()
                $0.clipsToBounds = true
                $0.layer.cornerRadius = 8
                $0.layer.borderWidth = 1
                $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
                $0.snp.makeConstraints { (make) in
                    make.left.equalTo(containerInset.left)
                    make.top.equalTo(lblTitle.snp.bottom).priority(.high)
                    make.size.equalTo(size)
                }
            }
        }
    }
    
    func stopLoadDummyView() {
        dummyViews.forEach { $0.removeFromSuperview() }
        stackView.isHidden = false
    }
    
    func setupDisplay(item: [T.Value]?) {
        itemsView.setupDisplay(item: item)
    }
}


// MARK: - Main Layout
typealias VatoMainLayoutCellProtocol = UpdateDisplayProtocol & LoadDummyProtocol
final class VatoMainLayoutCell<T: UIView>: UIView, UpdateDisplayProtocol, LoadDummyProtocol where T: UpdateDisplayProtocol, T: LoadDummyProtocol, T.Value: Equatable {
    let view = T(frame: .zero)
    typealias Value = T.Value
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        backgroundColor = .clear
        self.clipsToBounds = true
        view >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            }
        }
    }
    
    func loadDummyView() {
        view.loadDummyView()
    }
    
    func stopLoadDummyView() {
        view.stopLoadDummyView()
    }
    
    func setupDisplay(item: Value?) {
        view.setupDisplay(item: item)
    }
}

// MARK: - Cell
class VatoPromotionNewsBaseLayout<T: UIView>: Eureka.Cell<VatoHomeLandingItemSection>, CellType, LoadDummyProtocol, UpdateDisplayProtocol, Weakifiable, ActivityTrackingProgressProtocol where T: VatoMainLayoutCellProtocol, T.Value: Equatable {
    
    let containerView = VatoMainLayoutCell<T>.init(frame: .zero)
    let removeEvent: PublishSubject<Void> = PublishSubject()
    private (set) lazy var disposeBag = DisposeBag()
    private lazy var indicatorView = UIActivityIndicatorView(style: .gray)
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCache(key: String) -> Observable<Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> {
        let needLoadCache = DispatchQueue.loadCacheHome
        if needLoadCache {
            return CachedResourceManager.instance.load(key: key, type: OptionalMessageDTO<[VatoHomeLandingItem]>.self).map { (value) in
                if let value = value {
                    return .success(value)
                } else {
                    let e = NSError(use: "Need load")
                    return .failure(e)
                }
            }
        } else {
            let e = NSError(use: "Need load")
            return Observable.just(.failure(e))
        }
    }
    
    private func request(by router: APIRequestProtocol, key: String) -> Observable<Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let ignoreCache = DispatchQueue.ignoreCache
        return network.request(using: router,
                               decodeTo: OptionalMessageDTO<[VatoHomeLandingItem]>.self,
                               ignoreCache: ignoreCache).trackProgressActivity(indicator)
                    .do(onNext: { (r) in
                        do {
                            let v = try r.get()
                            
                            CachedResourceManager.instance.add(key: key, nameSource: "", value: v, isRoot: true)
                        } catch {
                            #if DEBUG
                                print(error.localizedDescription)
                            #endif
                        }
                                
                    })
    }
    
    func requestItems(id: String) -> Observable<Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> {
        var params: JSON = [:]
        var router = VatoAPIRouter.customPath(authToken: "", path: "landing-page/home/sections/\(id)/items", header: nil, params: params, useFullPath: false)
        let key = router.path + "position_\(id)"
        return loadCache(key: key).flatMap { (r) -> Observable<Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> in
            switch r {
            case .success:
                return Observable.just(r)
            case .failure:
                return VatoLocationManager.shared
                    .geoHash()
                    .flatMap { [weak self] (hash) -> Observable< Swift.Result<OptionalMessageDTO<[VatoHomeLandingItem]>, Error>> in
                    guard let wSelf = self else { return Observable.empty() }
                    let hash = hash
                    params["geohash"] = hash
                    router = VatoAPIRouter.customPath(authToken: "", path: "landing-page/home/sections/\(id)/items", header: nil, params: params, useFullPath: false)
                    return wSelf.request(by: router, key: key).retry(2)
                }
            }
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    func setupRX() {
        loadingProgress.skip(1).bind(onNext: weakify({ (i, wSelf) in
            i.0 ? wSelf.indicatorView.startAnimating() : wSelf.indicatorView.stopAnimating()
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        containerView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        adjustChildView()
        indicatorView >>> contentView >>> {
            $0.hidesWhenStopped = true
            $0.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: VatoHomeLandingItemSection?) {
        fatalError("Please implement!!!")
    }
    
    func adjustChildView() {
        fatalError("Please implement!!!")
    }
    
    func loadDummyView() {
        containerView.loadDummyView()
    }
    
    func stopLoadDummyView() {
        containerView.stopLoadDummyView()
    }
}

final class VatoPromotionNewsLayout1Cell: VatoPromotionNewsBaseLayout<VatoMainLayoutChildView<VatoMainItemLayout1>> {
    
    override func adjustChildView() {
        containerView.view.lblTitle.isHidden = true
        let childView = containerView.view.itemsView
        childView.clipsToBounds = true
        childView.layer.cornerRadius = 8
        childView.layer.borderWidth = 1
        childView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
    }
    
    
    override func setupDisplay(item: VatoHomeLandingItemSection?) {
        guard let p = item?.id else {
            return
        }
        
        requestItems(id: p).bind(onNext: weakify({ (res, wSelf) in
            switch res {
            case .success(let result):
                let items = (result.data ?? []).filter(\.status)
                defer {
                    if items.isEmpty {
                        wSelf.removeEvent.onNext(())
                    }
                }
                wSelf.containerView.setupDisplay(item: items)
            case .failure(let e):
                #if DEBUG
                print(e.localizedDescription)
                #endif
            }
        })).disposed(by: disposeBag)
    }
}

final class VatoPromotionNewsLayout2Cell: VatoPromotionNewsBaseLayout<VatoMainLayoutChildView<VatoMainItemLayout2>> {
    private (set) lazy var btnSeeAll = UIButton(frame: .zero)
    override func adjustChildView() {
        let childView = containerView.view.itemsView
        childView.clipsToBounds = false
        childView.collectionView.clipsToBounds = false
        let v = containerView.view
        let label = containerView.view.lblTitle
        btnSeeAll >>> v >>> {
            $0.isHidden = true
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
            $0.setTitle(FwiLocale.localized("Xem thêm"), for: .normal)
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalTo(label.snp.centerY)
            }
        }
    }
    
    override func setupDisplay(item: VatoHomeLandingItemSection?) {
        containerView.view.lblTitle.text = item?.title
        guard let p = item?.id else {
            return
        }
        
        requestItems(id: p).bind(onNext: weakify({ (res, wSelf) in
            switch res {
            case .success(let result):
                let items = (result.data ?? []).filter(\.status)
                defer {
                    if items.isEmpty {
                        wSelf.removeEvent.onNext(())
                    } else {
                        wSelf.btnSeeAll.isHidden = items.count <= 2
                    }
                }
                wSelf.containerView.setupDisplay(item: items)
            case .failure(let e):
                #if DEBUG
                print(e.localizedDescription)
                #endif
            }
        })).disposed(by: disposeBag)
    }
}
