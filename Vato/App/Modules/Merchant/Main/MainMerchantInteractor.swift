//  File name   : MainMerchantInteractor.swift
//
//  Author      : khoi tran
//  Created date: 10/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import KeyPathKit
import FwiCore
import FwiCoreRX
import RxCocoa

class ListMerchantDisplay: Equatable {
    var category: MerchantCategory?
    var listMerchant: [Merchant]?
    
    static func ==(lhs: ListMerchantDisplay, rhs: ListMerchantDisplay) -> Bool {
        return lhs.category?.id == rhs.category?.id
    }
}


protocol MainMerchantRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    
    func routeToMerchantDetail()
    func routeToCreateMerchantType()
    func routeToWebMerchant(token: String)
    func routeToEditMerchant(idMerchant: String, token: String)
}

protocol MainMerchantPresentable: Presentable {
    var listener: MainMerchantPresentableListener? { get set }
    func checkShowNoitemView()
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol MainMerchantListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func merchantMoveBack()
}


final class MainMerchantInteractor: PresentableInteractor<MainMerchantPresentable>, ActivityTrackingProgressProtocol, Weakifiable {
    /// Class's public properties.
    weak var router: MainMerchantRouting?
    weak var listener: MainMerchantListener?
    
    /// Class's constructor.
    init(presenter: MainMerchantPresentable, authStream: AuthenticatedStream?, merchantDataStream: MerchantDataStreamImpl? ) {
        self.authStream = authStream
        self.merchantDataStream = merchantDataStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestCategory()
        
        // todo: Implement business logic here.
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    
    private var authStream: AuthenticatedStream?
    private var merchantDataStream: MerchantDataStreamImpl?
    private lazy var mProgress: PublishSubject<Double> = PublishSubject()
    private lazy var errorSubject: PublishSubject<MerchantState> = PublishSubject()
    @VariableReplay private var subjectListMerchant: [ListMerchantDisplay] = []
    @VariableReplay var categoryMerchant: MerchantCategory? = nil
    
    private var paging: PagingEcom = .default
    private var isLoading: Bool = false
    private var dispose: Disposable?
}

// MARK: MainMerchantInteractable's members
extension MainMerchantInteractor: MainMerchantInteractable {
    func merchantDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func createMerchantTypeMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func reloadListMerchant() {
        paging = .default
        self.getListMerchant()
    }
    
    func refresh() {
        paging = .default
        getListMerchant()
    }
  
}

// MARK: MainMerchantPresentableListener's members
extension MainMerchantInteractor: MainMerchantPresentableListener {
    var eLoadingObser: Observable<(Bool, Double)> {
        return loadingProgress
    }
    
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObserver()
    }
    
    var listMerchantDisplay: Observable<[ListMerchantDisplay]>? {
        return $subjectListMerchant.asObservable()
    }
    
    
    var listMerchant: Observable<[Merchant]>? {
        return merchantDataStream?.listMerchant
    }
    
    func merchantMoveBack() {
        self.listener?.merchantMoveBack()
    }
    
    private func getListStore(merchant: Merchant?) {
//        let params:[String:Any] = ["sortCreateDate": true, "indexPage": 0, "sizePage": 1000]
        guard let selectedMechant = merchant
//            , let mId = selectedMechant.basic?.id
            else { return }
        merchantDataStream?.updateSelectedMerchant(merchant: selectedMechant)
        self.router?.routeToMerchantDetail()
//        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
//        let router = VatoFoodApi.listStoreByMerchant(authToken: "", merchantId: mId, params: params)
//        network.request(using: router, decodeTo: OptionalMessageDTO<StroreResponsePaging<Store>>.self).trackProgressActivity(indicator).bind(onNext: weakify({ (result, wSelf) in
//            switch result {
//            case .success(let r):
//                guard let d = r.data, let items = d.listStore?.groupBy(\.zoneId).map ({ $0.value }), !items.isEmpty else {
//                    return wSelf.moveToEditWeb(id: mId)
//                }
//                self.router?.routeToMerchantDetail()
//            case .failure(let e):
//                print(e.localizedDescription)
//                wSelf.moveToEditWeb(id: mId)
//            }
//            })).disposeOnDeactivate(interactor: self)
    }
    
    func moveToEditWeb(id: Int) {
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.router?.routeToEditMerchant(idMerchant: "\(id)", token: token)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func didSelectedMerchant(merchant: Merchant?) {
        getListStore(merchant: merchant)
    }
    
    func routeToCreateMerchantType() {
        self.merchantDataStream?.updateSelectedMerchant(merchant: nil)
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.router?.routeToWebMerchant(token: token)
        })).disposeOnDeactivate(interactor: self)
        

//        self.router?.routeToCreateMerchantType()
    }
    
    private func requestCategory() {
        let router = VatoFoodApi.listCategory(authToken: "", categoryId: nil, params: nil)
        let provider = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        provider.request(using: router, decodeTo: VatoNetwork.OptionalMessageDTO<MerchantCategory>.self).trackProgressActivity(indicator).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let res):
                wSelf.categoryMerchant = res.data
                wSelf.merchantDataStream?.updateListMerchantCategory(listMerchantCategory: res.data?.children ?? [])
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func requestListMerchant(p: PagingEcom) -> Observable<OptionalMessageDTO<MerchantResponsePaging<Merchant>>> {
        guard let userId = UserManager.instance.userId else {
            return Observable.empty()
        }
        let params = p.params
        let router = VatoFoodApi.listMerchant(authToken: "", ownerId: userId, isFull: true, params: params)
        let provider = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return provider.request(using: router, decodeTo: OptionalMessageDTO<MerchantResponsePaging<Merchant>>.self).map { try $0.get() }
    }
    
    func getListMerchant() {
        let first = paging.page == -1
        guard !isLoading || first else {
            return
        }
        
        guard let p = paging.next else {
            return
        }
        dispose?.dispose()
        dispose = Observable.zip($categoryMerchant.filterNil().take(1), requestListMerchant(p: p)).trackProgressActivity(indicator).observeOn(MainScheduler.asyncInstance).bind { [weak self] (c1, m2) in
            guard let wSelf = self else { return}
            if let e = m2.error {
                wSelf.errorSubject.onNext(.errorSystem(err: e))
                return
            }
            
            let listMerchantCategory:[MerchantCategory] = c1.children ?? []
            guard var data = m2.data else { return }
            let s = data.content?.count ?? 0
            let next = s == p.size
            wSelf.paging = PagingEcom(page: p.page, canRequest: next, size: p.size)
            data.content = data.content.map { l -> [Merchant] in
                return l.map{ m -> Merchant in
                    var newMerchant = m
                    newMerchant.category = listMerchantCategory.filter{ newMerchant.categoryId != nil && $0.id! == newMerchant.categoryId! }.first
                    return newMerchant
                }
            }
            
            let listMerchantDisplay = data.content?.groupBy(\.categoryId).map{ m -> ListMerchantDisplay in
                let merchantDisplay = ListMerchantDisplay()
                merchantDisplay.category = m.value.first?.category
                merchantDisplay.listMerchant = m.value
                return merchantDisplay
            }
            
            if first {
                wSelf.subjectListMerchant = listMerchantDisplay ?? []
            } else {
                var current = wSelf.subjectListMerchant
                listMerchantDisplay?.forEach({ (item) in
                    guard let i = current.first(where: { $0 == item }), let new = item.listMerchant, !new.isEmpty  else {
                        current.append(item)
                        return
                    }
                    let c = i.listMerchant ?? []
                    i.listMerchant = c + new
                })
                
                wSelf.subjectListMerchant = current
            }
        }
    }
}

// MARK: Class's private methods
private extension MainMerchantInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        loadingProgress.bind(onNext: weakify({ (item, wSelf) in
            wSelf.isLoading = item.0
        })).disposeOnDeactivate(interactor: self)
        
    }
}

