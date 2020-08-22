//  File name   : TopUpByThirdPartyInteractor.swift
//
//  Author      : khoi tran
//  Created date: 2/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore
import VatoNetwork
import Alamofire

protocol TopUpByThirdPartyRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TopUpByThirdPartyPresentable: Presentable {
    var listener: TopUpByThirdPartyPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TopUpByThirdPartyListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func topUpMoveBack()
    
}

final class TopUpByThirdPartyInteractor: PresentableInteractor<TopUpByThirdPartyPresentable> {
    /// Class's public properties.
    weak var router: TopUpByThirdPartyRouting?
    weak var listener: TopUpByThirdPartyListener?
    
    
    /// Class's constructor.
    init(presenter: TopUpByThirdPartyPresentable, paymentStream: MutablePaymentStream, authStream: AuthenticatedStream, mutableTopUpStream: MutableTopUpStream) {
        self.paymentStream = paymentStream
        self.authStream = authStream
        self.mutableTopUpStream = mutableTopUpStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        mLastSelectedCard = listSelectedCard.first
        setupRX()
        
        // todo: Implement business logic here.
        self.requestConfig()
        
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private let paymentStream: MutablePaymentStream
    private let authStream: AuthenticatedStream
    private let mutableTopUpStream: MutableTopUpStream
    
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    @CacheFile(fileName: "TopUpCard") var listSelectedCard: [Card]
    private var mLastSelectedCard: Card?
//    @Replay(queue: MainScheduler.asyncInstance) private var mCard: [Card]
    
    @Published private var mListConfigs: [TopupConfigResponse]
}

// MARK: TopUpByThirdPartyInteractable's members
extension TopUpByThirdPartyInteractor: TopUpByThirdPartyInteractable {
    
}

// MARK: TopUpByThirdPartyPresentableListener's members
extension TopUpByThirdPartyInteractor: TopUpByThirdPartyPresentableListener {
    func topUpMoveBack() {
        self.listener?.topUpMoveBack()
    }
    
    var listTopUpCell: Observable<[TopupCellModel]> {
        return mutableTopUpStream.listTopUpCellModel
    }
    
    func selectCard(card: Card?) {
        _listSelectedCard.add(item: card)
    }
    
    func saveCard() {
        _listSelectedCard.save()
    }
    
    var lastSelectedCard: Card? {
        return mLastSelectedCard
    }
}

// MARK: Class's private methods
private extension TopUpByThirdPartyInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        Observable.combineLatest($mListConfigs, self.paymentStream.source).observeOn(MainScheduler.asyncInstance).bind {[weak self] (listConfig, cards) in
            guard let me = self else { return }
            me.mutableTopUpStream.updateListTopUp(listTopUpLinkConfig: listConfig, listCard: cards)
        }.disposeOnDeactivate(interactor: self)
        
    }
    
    typealias RequestConfigResponse = VatoNetwork.Response<OptionalMessageDTO<[TopupConfigResponse]>>
    func requestConfig() {
                
        self.request { (token) -> Observable<RequestConfigResponse> in
            return Requester.responseDTO(decodeTo: OptionalMessageDTO<[TopupConfigResponse]>.self, using: VatoAPIRouter.userTopupConfig(authToken: token), progress: nil)
        }
        .trackProgressActivity(self.trackProgress)
        .subscribe(onNext: { [weak self] (r) in
            guard let wSelf = self else { return }
            if r.response.fail == true {
                
            } else {
                if let result = r.response.data {
                    wSelf.mListConfigs = result.filter({ $0.active == true })
                }
            }
        }).disposeOnDeactivate(interactor: self)
    }
}


extension TopUpByThirdPartyInteractor: RequestInteractorProtocol {
    var token: Observable<String> {
        return authStream.firebaseAuthToken.take(1)
    }
    
    
}
