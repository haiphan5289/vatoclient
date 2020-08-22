//  File name   : QuickSupportMainInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol QuickSupportMainRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToListQS()
    
    func routeRequestQickSupport(requestModel: QuickSupportRequest)
}

protocol QuickSupportMainPresentable: Presentable {
    var listener: QuickSupportMainPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol QuickSupportMainListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func quickSupportMoveBack()
}

final class QuickSupportMainInteractor: PresentableInteractor<QuickSupportMainPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: QuickSupportMainRouting?
    weak var listener: QuickSupportMainListener?

    /// Class's constructor.
    override init(presenter: QuickSupportMainPresentable) {
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
    @Published private var mListQuickSuppsort: [QuickSupportRequest]
}

// MARK: QuickSupportMainInteractable's members
extension QuickSupportMainInteractor: QuickSupportMainInteractable {

    func requestSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func quickSupportListMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: QuickSupportMainPresentableListener's members
extension QuickSupportMainInteractor: QuickSupportMainPresentableListener {
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : InitializeValueProtocol {
        return QuickSupportManager.instance.listQuickSupport.map { (data) -> T in
            let news = data.enumerated().map { old -> QuickSupportRequest in
                var new = old.element
                new.index = old.offset + 1
                return new
            }
            guard let m = T(use: news) else {
                fatalError("has not been implemented")
            }
            return m
        }
    }
    
    func routeRequestQickSupport(requestModel: QuickSupportRequest) {
        router?.routeRequestQickSupport(requestModel: requestModel)
    }
    
    var listQuickSupport: Observable<[QuickSupportRequest]> {
        return $mListQuickSuppsort
    }
    
    func quickSupportMoveBack() {
        self.listener?.quickSupportMoveBack()
    }
    
    func routeToListQS() {
        self.router?.routeToListQS()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension QuickSupportMainInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
}
