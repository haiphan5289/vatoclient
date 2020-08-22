//  File name   : EcomPromotionInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol EcomPromotionRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol EcomPromotionPresentable: Presentable {
    var listener: EcomPromotionPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol EcomPromotionListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ecomPromotionMoveBack()
    func ecomPromotion(selected: EcomPromotion)
    func ecomPromotionVoucher(string: String?)
}

final class EcomPromotionInteractor: PresentableInteractor<EcomPromotionPresentable> {
    /// Class's public properties.
    weak var router: EcomPromotionRouting?
    weak var listener: EcomPromotionListener?
    let storeID: Int
    /// Class's constructor.
    init(presenter: EcomPromotionPresentable, storeID: Int) {
        self.storeID = storeID
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
}

// MARK: EcomPromotionInteractable's members
extension EcomPromotionInteractor: EcomPromotionInteractable {
}

// MARK: EcomPromotionPresentableListener's members
extension EcomPromotionInteractor: EcomPromotionPresentableListener {
    func ecomPromotionVoucher(string: String?) {
        listener?.ecomPromotionVoucher(string: string)
    }
    
    func ecomPromotionMoveBack() {
        listener?.ecomPromotionMoveBack()
    }
    
    func ecomPromotion(selected: EcomPromotion) {
        listener?.ecomPromotion(selected: selected)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : InitializeValueProtocol {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<T>.self)
            .map {
                try $0.get().data
            }
            .filterNil()
    }
}

// MARK: Class's private methods
private extension EcomPromotionInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
