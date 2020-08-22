//  File name   : QuickSupportListInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol QuickSupportListRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToQuickSupportDetail(model: QuickSupportModel)
}

protocol QuickSupportListPresentable: Presentable {
    var listener: QuickSupportListPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol QuickSupportListListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func quickSupportListMoveBack()
}

final class QuickSupportListInteractor: PresentableInteractor<QuickSupportListPresentable> {
    /// Class's public properties.
    weak var router: QuickSupportListRouting?
    weak var listener: QuickSupportListListener?

    /// Class's constructor.
    override init(presenter: QuickSupportListPresentable) {
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

// MARK: QuickSupportListInteractable's members
extension QuickSupportListInteractor: QuickSupportListInteractable {
    func quickSupportDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
}

// MARK: QuickSupportListPresentableListener's members
extension QuickSupportListInteractor: QuickSupportListPresentableListener {
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
         let documentRef = Firestore.firestore().documentRef(collection: .custom(id: "QuickSupportDummy"), storePath: .custom(path: "Detail") , action: .read)
                       
        return documentRef.find(action: .get, json: nil)
                   .filterNil()
                   .map {
                       try $0.decode(to: T.self)
                   }
    }
    
    func detail(model: QuickSupportModel) {
        self.router?.routeToQuickSupportDetail(model: model)
    }
    
    func quickSupportListMoveBack() {
        self.listener?.quickSupportListMoveBack()
    }
}

// MARK: Class's private methods
private extension QuickSupportListInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
