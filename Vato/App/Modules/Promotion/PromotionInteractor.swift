//  File name   : PromotionInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import VatoNetwork

protocol PromotionRouting: ViewableRouting, RoutableProtocol {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToSearch()
    func routeToDetail()
    func routeFocusSearch()
    func showToast() -> Observable<Void>
    func showAlert(_ error: Error)
}

protocol PromotionPresentable: Presentable {
    var listener: PromotionPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PromotionListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func promotionMoveBack()
    func update(model: PromotionModel?)
}

final class PromotionInteractor: PresentableInteractor<PromotionPresentable>, PromotionInteractable, PromotionPresentableListener, UsePromotionProtocol, ActivityTrackingProgressProtocol {
    weak var router: PromotionRouting?
    weak var listener: PromotionListener?
    private(set) var authenticatedStream: AuthenticatedStream
    private let promotionDataStream: MutablePromotionDataStream
    private let promotionSearchStream: MutablePromotionSearchStream
    private let transportStream: TransportStream?
    private(set) lazy var command: PublishSubject<PromotionCommand> = PublishSubject()
    private var currentKeyword: String?
    private(set) var currentSelectService: ServiceCanUseProtocol?
    private(set) var typeList: PromotionListType
    private let coordinate: CLLocationCoordinate2D?
    
    var manifest: PromotionList.Manifest? {
        return self.promotionDataStream.currentSelect?.manifest
    }
    
    var code: String {
        return self.promotionDataStream.currentSelect?.state.code ?? ""
    }
    
    var eSource: PromotionDataStream {
        return promotionDataStream
    }
    
    var eLoading: Observable<(Bool, Double)> {
        return indicator.asObservable()
    }

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: PromotionPresentable,
         authenticatedStream: AuthenticatedStream,
         promotionDataStream: MutablePromotionDataStream,
         promotionSearchStream: MutablePromotionSearchStream,
         transportStream: TransportStream?,
         typeList: PromotionListType,
         coordinate: CLLocationCoordinate2D?)
    {
        self.coordinate = coordinate
        self.authenticatedStream = authenticatedStream
        self.promotionDataStream = promotionDataStream
        self.promotionSearchStream = promotionSearchStream
        self.transportStream = transportStream
        self.typeList = typeList
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        setupRX()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func setupRX() {
        self.transportStream?.selectedService.take(1).bind { [weak self] in
            self?.currentSelectService = $0
        }.disposeOnDeactivate(interactor: self)
        
        self.command.bind { [weak self](command) in
            guard let wSelf = self else {
                return
            }
            
            switch command {
            case .detailList(let index):
                wSelf.detailItemList(at: index)
                
            case .actionSearch(let obj):
                guard let obj = obj else {
                    return
                }
                wSelf.promotionDataStream.update(select: obj)
                wSelf.use(code: obj.state.code)
                
            case .detailSearch(let obj):
                wSelf.detail(from: obj)
                
            case .reload:
                fatalError("Please Implement")
                
            case .updateData:
                fatalError("Please Implement")
                
            case .actionList(let index):
                wSelf.applyCode(at: index)
            case .applyPromotion:
                guard let code = self?.promotionDataStream.currentSelect?.state.code else {
                    return
                }
                wSelf.use(code: code)
            }
            
        }.disposeOnDeactivate(interactor: self)
    }
    
    func promotionMoveBack() {
        listener?.promotionMoveBack()
    }
    
    func routeToSearch() {
        router?.routeToSearch()
    }
    
    func dismissDetail() {
        router?.detachCurrentRoute()
        router?.routeFocusSearch()
    }
    
    func detachCurrentChild() {
        self.router?.detachCurrentChild()
    }
    
    func detachCurrentRoute() {
        self.router?.detachCurrentRoute()
    }
    
    func applyCode(at idx: IndexPath) {
        self.itemList(at: idx).filterNil().do(onNext: { [weak self] in
            self?.keepItemNextRound(from: $0)
        }).bind { [weak self](_) in
            self?.command.onNext(.applyPromotion)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func itemList(at idx: IndexPath) -> Observable<PromotionDisplayProtocol?> {
        return self.promotionDataStream.listDefault.take(1).map{ $0[safe: idx.item] }
    }
    
    private func keepItemNextRound(from obj: PromotionDisplayProtocol?) {
        guard let obj = obj else {
            return
        }
        
        self.promotionDataStream.update(select: obj)
    }
    
    private func detailItemList(at idx: IndexPath) {
        _ = self.itemList(at: idx).filterNil().bind { [weak self] in
            self?.detail(from: $0)
        }
    }
    
    
    private func detail(from obj: PromotionDisplayProtocol?) {
        keepItemNextRound(from: obj)
        UIApplication.shared.keyWindow?.endEditing(true)
        router?.routeToDetail()
    }
    
    func use(code: String) {
        let manifest = self.promotionDataStream.currentSelect?.manifest
        self.requestPromotionData(from: code)
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.indicator)
            .map({ data -> PromotionModel in
                let model = PromotionModel(with: code)
                model.data = data
                model.mainfest = manifest
                return model
            }).subscribe(onNext: { [weak self](model) in
                self?.usePromotion(from: model)
            }, onError: { [weak self](e) in
                self?.router?.showAlert(PromotionError.applyCode(e: e))
                if let promotionDetailRouter = (self?.router?.children.filter { $0 is PromotionDetailRouter })?.first as? PromotionDetailRouter,
                    let vc = promotionDetailRouter.viewController as? PromotionDetailVC {
                    vc.setupEnableActionButton()
                }
            }).disposeOnDeactivate(interactor: self)
    }
    
    private func usePromotion(from model: PromotionModel?) {
        switch typeList {
        case .home:
            self.router?.showToast().subscribe(onNext: { [weak self](_) in
                self?.listener?.update(model: model)
            }).disposeOnDeactivate(interactor: self)
        case .booking:
            self.listener?.update(model: model)
        }
    }
    
    func loadData() {
        requestListPromotion()
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.indicator)
            .map { ResponseResult.success(items: $0.data) }
            .catchError { Observable.just(ResponseResult.fail(error: $0)) }
            .bind { [weak self] in
                self?.promotionDataStream.update(listDefault: $0, filterBy: self?.currentSelectService)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private var disposeSearch: Disposable?
    func search(by keyword: String?) {
        guard self.currentKeyword != keyword else {
            return
        }
        
        disposeSearch?.dispose()
        guard let keyword = keyword, !keyword.isEmpty  else {
            // Reset
            self.promotionSearchStream.resetListSearch()
            return
        }
        self.currentKeyword = keyword
        
        disposeSearch = self.requestSearchPromotion(by: keyword)
            .observeOn(MainScheduler.instance)
            .map { ResponseResult.success(items: $0.data.listDisplay().filter({ (p) -> Bool in
                p.state.code.uppercased() == keyword.uppercased()
            }))}
            .catchError { Observable.just(ResponseResult.fail(error: $0))}
            .bind { [weak self](result) in
                self?.promotionSearchStream.new(listSearch: result)
        }
    }
    
    private func requestListPromotion() -> Observable<MessageDTO<PromotionList>> {
        let coordinate = self.coordinate ?? VatoLocationManager.shared.location?.coordinate
        return authenticatedStream
            .firebaseAuthToken.take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, MessageDTO<PromotionList>)> in
                Requester.requestDTO(using: VatoAPIRouter.promotionList(authToken: key, coordinate: coordinate),
//                                     encoding: JSONEncoding.default,
                                     block: { $0.dateDecodingStrategy = .customDateFireBase })
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.errorCode ?? ""])
                }
                return data
            }.do(onNext: { (res) in
                PromotionManager.shared.update(list: res.data) })
    }
    
    private func requestSearchPromotion(by keyword: String) -> Observable<MessageDTO<PromotionList>> {
        return authenticatedStream
            .firebaseAuthToken.take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, MessageDTO<PromotionList>)> in
                Requester.requestDTO(using: VatoAPIRouter.promotionSearch(authToken: key, code: keyword), method: .get, block: { $0.dateDecodingStrategy = .customDateFireBase })
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.errorCode ?? ""])
                }
                return data
        }
    }
}

protocol UsePromotionProtocol {
    var authenticatedStream: AuthenticatedStream { get }
}

extension UsePromotionProtocol {
    func requestPromotionData(from code: String) -> Observable<PromotionData> {
        return authenticatedStream
            .firebaseAuthToken
            .take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, PromotionData)> in
                Requester.requestDTO(using: VatoAPIRouter.promotion(authToken: key, code: code), method: .post, encoding: JSONEncoding.default, block: { $0.dateDecodingStrategy = .customDateFireBase })
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    let m = data.errorCode?.components(separatedBy: ".").last ?? ""
                    let message: String
                    switch m {
                    case "MasterCodeDayExceedException", "TodayExceedException", "UserCodeExceedTodayException":
                        message = PromotionConfig.promotionExceedDay
                    default:
                        message = PromotionConfig.promotionApplyForAllError
                    }
                    
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: message])
                }
                return data
        }
    }
    
    func revertPromotion(from promotionToken: String?) -> Observable<Data>{
        guard let promotionToken = promotionToken, !promotionToken.isEmpty else {
            return Observable.empty()
        }
        
        return authenticatedStream
            .firebaseAuthToken
            .take(1)
            .timeout(7.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                return Requester.request(using: VatoAPIRouter.promotionCancel(authToken: authToken, promotionToken: promotionToken),
                                         method: .post, encoding: JSONEncoding.default)
            }.map { $0.1 }
    }
}
