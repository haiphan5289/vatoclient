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

final class QuickSupportMainInteractor: PresentableInteractor<QuickSupportMainPresentable> {
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
    func request<T>(router: APIRequestProtocol, decodeTo:
        T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        
        
        let documentRef = Firestore.firestore().documentRef(collection: .custom(id: "QuickSupportDummy"), storePath: .custom(path: "Home") , action: .read)
                
        return documentRef.find(action: .get, json: nil)
            .filterNil()
            .map {
                try! $0.decode(to: T.self)
            }
        
            
        
        
        
//        let quickSupportUrl = Bundle.main.url(forResource: "quick-support", withExtension: "json")
//
//        let mockupRequest = MockupManagerRequest.init(1) { (url, method, parameter, encoding, header) -> NetworkResponse in
//            return NetworkResponse(response: nil, data: try Data.init(contentsOf: quickSupportUrl!))
//        }
//        let networkRequester = NetworkRequester(provider: mockupRequest)
//
//        return networkRequester.request(using: router, decodeTo: decodeTo, method: .get, encoding: JSONEncoding.default, block: nil).map { (r) -> T in
//            switch r {
//            case .success(let t):
//                return t
//            case .failure(let e):
//                throw e
//            }
//        }
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
    
    
}

// MARK: Class's private methods
private extension QuickSupportMainInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
}
