//  File name   : MerchantDetailInteractor.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCore
import FwiCoreRX

protocol MerchantDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToAddStore()
    func routeToCreateMerchantDetail()
    func routeToStoreDetail()
    func routeToEditMerchant(idMerchant: String, token: String)
}

protocol MerchantDetailPresentable: Presentable {
    var listener: MerchantDetailPresentableListener? { get set }
    func checkShowItemView()
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol MerchantDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    
    func merchantDetailMoveBack()
    func reloadListMerchant()
}

final class MerchantDetailInteractor: PresentableInteractor<MerchantDetailPresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: MerchantDetailRouting?
    weak var listener: MerchantDetailListener?
    
    /// Class's constructor.
    init(presenter: MerchantDetailPresentable, authStream: AuthenticatedStream, merchantStream: MerchantDataStream) {
        
        super.init(presenter: presenter)
        self.merchantStream = merchantStream
        self.authStream = authStream
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private var authStream: AuthenticatedStream?
    private var merchantStream: MerchantDataStream?
    
    private var subjectListStore: PublishSubject<[[Store]]> = PublishSubject()
    private lazy var errSubject: PublishSubject<MerchantState> = PublishSubject()
    
}

// MARK: MerchantDetailInteractable's members
extension MerchantDetailInteractor: MerchantDetailInteractable {
    func refresh() {
        
    }
    
    
    func storeDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func reloadListMerchant() {
        self.listener?.merchantDetailMoveBack()
        self.listener?.reloadListMerchant()
    }
    
    func createMerchantDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func addStoreMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func reloadListStore() {
        self.router?.dismissCurrentRoute(completion: nil)
        self.getListStore()
    }
    
    
}

// MARK: MerchantDetailPresentableListener's members
extension MerchantDetailInteractor: MerchantDetailPresentableListener, Weakifiable {
    
    var currentSelectedMerchant: Observable<Merchant?> {
        return merchantStream!.currentSelectedMerchantObservable
    }
    
    var eLoadingObserable: Observable<Bool> {
        return self.indicator.asObservable()
    }
    var errorObserable: Observable<MerchantState> {
        return errSubject.asObserver()
    }
    
    var listStore: Observable<[[Store]]>? {
        return subjectListStore.asObserver()
    }
    
    
    func backToMainMerchant() {
        self.listener?.merchantDetailMoveBack()
    }
    
    func excuteStoreCommand(command: StoreCommand) {
        
        if let merchantStream = self.merchantStream as? MerchantDataStreamImpl {
            merchantStream.updateStoreCommnand(s: command)
            switch command {
            case .addNew:
                merchantStream.updateCurrentSelectedStore(s: nil)
                self.router?.routeToAddStore()
            case .edit(let s):
                merchantStream.updateCurrentSelectedStore(s: s)
                self.router?.routeToStoreDetail()
            }
        }
    }
    
    
    func getListStore() {
        let params:[String:Any] = ["sortCreateDate": true, "indexPage": 0, "sizePage": 1000]

        if let authenStream = self.authStream, let selectedMechant = self.merchantStream?.currentSelectedMerchant {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap{
                    Requester.responseDTO(decodeTo: VatoNetwork.OptionalMessageDTO<StroreResponsePaging<Store>>.self,
                                               using: VatoFoodApi.listStoreByMerchant(authToken: $0, merchantId: selectedMechant.basic?.id ?? -1, params: params),
                                               method: .get,
                                               progress: { _ in
                    })
                }
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if r.response.fail == true {
                        if let message = r.response.message {
                            let errType = MerchantState.generalError(status: r.response.status,
                                                                     message: message)
                            self?.errSubject.onNext(errType)
                        }
                    } else {
                        if let result = r.response.data {
                            
                            let data = result.listStore?.groupBy(\.zoneId).map({$0.value})
                            self?.subjectListStore.onNext(data ?? [[]])
                        }
                    }
                    self?.presenter.checkShowItemView()
                    }, onError: {[weak self] (e) in
                        self?.errSubject.onNext(.errorSystem(err: e))
                        self?.presenter.checkShowItemView()
                }).disposeOnDeactivate(interactor: self)
        }
        
    }
    
    func routeToCreateMerchantDetail() {
        guard let selectedMechant = self.merchantStream?.currentSelectedMerchant,
            let id = selectedMechant.basic?.id else {
            return
        }
        self.moveToEditWeb(id: id)
    }
    
    func moveToEditWeb(id: Int) {
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.router?.routeToEditMerchant(idMerchant: "\(id)", token: token)
        })).disposeOnDeactivate(interactor: self)
    }
}
//
// MARK: Class's private methods
private extension MerchantDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
