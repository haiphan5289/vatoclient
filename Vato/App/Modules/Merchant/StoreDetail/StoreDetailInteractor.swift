//  File name   : StoreDetailInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol StoreDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    
    func routeToProductDetail(currentProduct: DisplayProduct?)
    func routeToAddStore()
    func routeToListProduct()
}

protocol StoreDetailPresentable: Presentable {
    var listener: StoreDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    
}

protocol StoreDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func storeDetailMoveBack()
    func reloadListStore()

}

final class StoreDetailInteractor: PresentableInteractor<StoreDetailPresentable> {
    /// Class's public properties.
    weak var router: StoreDetailRouting?
    weak var listener: StoreDetailListener?

    /// Class's constructor.
    init(presenter: StoreDetailPresentable, merchantStream: MerchantDataStream, authStream: AuthenticatedStream) {
        self.merchantStream = merchantStream
        self.authStream = authStream
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
    private var merchantStream: MerchantDataStream?
    private var authStream: AuthenticatedStream?
}

// MARK: StoreDetailInteractable's members
extension StoreDetailInteractor: StoreDetailInteractable {
    func dismissListProduct() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func addStoreMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func reloadListStore() {
        self.listener?.reloadListStore()
        self.listener?.storeDetailMoveBack()
    }
    
    func addProductMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    var currentStore: Store? {
        return self.merchantStream?.currentSelectedStore
    }
}

// MARK: StoreDetailPresentableListener's members
extension StoreDetailInteractor: StoreDetailPresentableListener {
    func storeDetailMoveBack() {
        self.listener?.storeDetailMoveBack()
    }
    
   
    
    func routeToNextScreen(command: StoreDetailCommand) {
        switch command {
        case .productInfo:
            self.router?.routeToListProduct()
        case .storeInfo:
            self.router?.routeToAddStore()
        }
    }

}

// MARK: Class's private methods
private extension StoreDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}

