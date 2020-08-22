//  File name   : ListProductInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol ListProductRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToProductDetail(currentProduct: DisplayProduct?)
}

protocol ListProductPresentable: Presentable {
    var listener: ListProductPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ListProductListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissListProduct()
}

final class ListProductInteractor: PresentableInteractor<ListProductPresentable>, RequestInteractorProtocol {
    struct Config {
        
        
        struct Tracking {
            
        }
    }
    
    /// Class's public properties.
    weak var router: ListProductRouting?
    weak var listener: ListProductListener?

    /// Class's constructor.
    init(presenter: ListProductPresentable, authStream: AuthenticatedStream, merchantStream: MerchantDataStream) {
        self.authStream = authStream
        self.merchantStream = merchantStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        self.getListProduct()
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var authStream: AuthenticatedStream
    private var merchantStream: MerchantDataStream
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)
    private var listProductCategorySubject: PublishSubject<[DisplayProductCategory]> = PublishSubject<[DisplayProductCategory]>()

    var token: Observable<String> {
        return authStream.firebaseAuthToken.take(1)
    }
}

// MARK: ListProductInteractable's members
extension ListProductInteractor: ListProductInteractable {
    func addProductMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }

    
}

// MARK: ListProductPresentableListener's members
extension ListProductInteractor: ListProductPresentableListener {
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObserver()
    }
    
    var listProductCategory: Observable<[DisplayProductCategory]> {
        return listProductCategorySubject.asObservable()
    }

    func dismisListProduct() {
        self.listener?.dismissListProduct()
    }
    
    func routeToAddProduct(currentProduct: DisplayProduct?) {
        self.router?.routeToProductDetail(currentProduct: currentProduct)
    }
    
    
    var currentStore: Store? {
        return merchantStream.currentSelectedStore
    }
    
    func refresh() {
        self.getListProduct()
    }
    
    typealias PublicProductResponse =  (HTTPURLResponse, OptionalMessageDTO<String>)
    func publicProduct(productId: Int?, value: Bool) {
        guard let productId = productId else {
            return
        }
        
        self.request { (token) -> Observable<PublicProductResponse> in
            Requester.requestDTO(
                using: VatoFoodApi.editOnOffProduct(authToken: token, productId: productId, isOn: value, params: nil),
                                 method: .put,
                                 encoding: JSONEncoding.default)
            
            }.trackProgressActivity(self.trackProgress)
            .subscribe(onNext: { [weak self] (r) in
                if r.1.fail == true {
                    guard let message = r.1.message else { return }
                    let errType = MerchantState.generalError(status: r.1.status,
                                                             message: message)
                    self?.errorSubject.onNext(errType)
                } else {
                    if let result = r.1.data {
                        printDebug(result)
                    }
                }
                }, onError: {[weak self] (e) in
                    self?.errorSubject.onNext(.errorSystem(err: e))
            }).disposeOnDeactivate(interactor: self)
    }
}


// MARK: Class's private methods
private extension ListProductInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    typealias ListDisplayProductResponse = VatoNetwork.Response<OptionalMessageDTO<[DisplayProductCategory]>>
    func getListProduct() {
       
        guard let storeId = merchantStream.currentSelectedStore?.id else {
            return
        }
        
        let request = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let router = VatoFoodApi.listDisplayProduct(authToken: "", storeId: storeId, statusList:"", params: ["statusList":"-1"])
        
        request.request(using: router, decodeTo: OptionalMessageDTO<[DisplayProductCategory]>.self).trackProgressActivity(self.trackProgress).bind {[weak self] (result) in
            switch result {
            case .success(let r):
                if r.fail == true {
                    guard let message = r.message else { return }
                    let errType = MerchantState.generalError(status: r.status,
                                                             message: message)
                    self?.errorSubject.onNext(errType)
                } else {
                    if let result = r.data {
                        printDebug(result)
                        self?.listProductCategorySubject.onNext(result)
                    }
                }
            case .failure(let e):
                self?.errorSubject.onNext(.errorSystem(err: e))
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
}
