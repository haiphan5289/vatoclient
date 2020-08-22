//  File name   : AddProductTypeInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork



protocol AddProductTypeRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol AddProductTypePresentable: Presentable {
    var listener: AddProductTypePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    
}

protocol AddProductTypeListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func addProductTypeMoveBack()
    func setCategory(text: String, category: MerchantCategory)
}

final class AddProductTypeInteractor: PresentableInteractor<AddProductTypePresentable> {
    /// Class's public properties.
    weak var router: AddProductTypeRouting?
    weak var listener: AddProductTypeListener?

    /// Class's constructor.
    init(presenter: AddProductTypePresentable, authStream: AuthenticatedStream, merchantStream: MerchantDataStream, listPathCategory: [MerchantCategory]?) {
        self.authStream = authStream
        self.merchantStream = merchantStream
        self.mListPathCategory = listPathCategory
        super.init(presenter: presenter)
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
    
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private var listCategorySubject: PublishSubject<[MerchantCategory]?> = PublishSubject<[MerchantCategory]?>()
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)

    private let mListPathCategory: [MerchantCategory]?
}

// MARK: AddProductTypeInteractable's members
extension AddProductTypeInteractor: AddProductTypeInteractable {
}

// MARK: AddProductTypePresentableListener's members
extension AddProductTypeInteractor: AddProductTypePresentableListener {
   
    func getListMainCategory() {
        guard let categoryId = merchantStream?.currentSelectedMerchant?.categoryId else {
            return
        }
        
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({
                    Requester.responseCacheDTO(decodeTo: VatoNetwork.OptionalMessageDTO<MerchantCategory>.self,
                                               using: VatoFoodApi.listCategory(authToken: $0, categoryId: categoryId, params: nil),
                                               method: .get)
                })
                .trackProgressActivity(self.trackProgress)
                .subscribe(onNext: { [weak self] (r) in
                    if r.response.fail == true {
                        guard let message = r.response.message else { return }
                        let errType = MerchantState.generalError(status: r.response.status,
                                                                 message: message)
                        self?.errorSubject.onNext(errType)
                    } else {
                        if let result = r.response.data {
                            self?.listCategorySubject.onNext(result.children)
                        }
                    }
                    }, onError: {[weak self] (e) in
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func setCategory(text: String, category: MerchantCategory) {
        self.addProductTypeMoveBack()
        self.listener?.setCategory(text: text, category: category)
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObserver()
    }
    
    var listCategoryObservable: Observable<[MerchantCategory]?> {
        return listCategorySubject.asObserver().observeOn(MainScheduler.asyncInstance)
    }
    
    func addProductTypeMoveBack() {
        self.listener?.addProductTypeMoveBack()
    }
    
    var listPathCategory: [MerchantCategory]? {
        return mListPathCategory
    }
}

// MARK: Class's private methods
private extension AddProductTypeInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    
    
    
}
