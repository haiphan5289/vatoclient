//  File name   : CreateMerchantTypeInteractor.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCore
import FwiCoreRX

enum MerchantState {
    case noData
    case badRequest
    case errorSystem(err: Error)
    case notFound
    case unauthorized
    case internalServerError
    case other(message: String)
    
    func getMsg() -> String {
        switch self {
        case .noData:
            return Text.noData.localizedText
        case .errorSystem(let e):
            let code = (e as NSError).code
            if code == NSURLErrorNotConnectedToInternet ||
                code == NSURLErrorBadServerResponse {
                return Text.networkDownDescription.localizedText
            } else {
                return Text.thereWasAnErrorFunction.localizedText
            }
        case .badRequest:
            return Text.badRequest.localizedText
        case .notFound:
            return Text.notFound.localizedText
        case .unauthorized:
            return Text.unauthorized.localizedText
        case .internalServerError:
            return Text.internalServerError.localizedText
        case .other(let message):
            return message
        }
    }
    static func generalError (status: Int, message: String) -> MerchantState {
//        if Config.badRequest == status {
//            return MerchantState.badRequest
//        } else if Config.notFound == status {
//            return MerchantState.notFound
//        } else if Config.unauthorized == status {
//            return MerchantState.unauthorized
//        } else if Config.internalServerError == status {
//            return MerchantState.internalServerError
//        }
        return MerchantState.other(message: message)
    }
    struct Config {
        static let badRequest = 400
        static let unauthorized = 401
        static let notFound = 404
        static let internalServerError = 500
    }
}

protocol CreateMerchantTypeRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToCreateMerchantDetail(category: MerchantCategory)
}

protocol CreateMerchantTypePresentable: Presentable {
    var listener: CreateMerchantTypePresentableListener? { get set }
    func checkShowEmptyView()
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol CreateMerchantTypeListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func createMerchantTypeMoveBack()
    func reloadListMerchant()
}

final class CreateMerchantTypeInteractor: PresentableInteractor<CreateMerchantTypePresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: CreateMerchantTypeRouting?
    weak var listener: CreateMerchantTypeListener?
    private var listCategoriesSubject: ReplaySubject<MerchantCategory> = ReplaySubject.create(bufferSize: 1)
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()

    /// Class's constructor.
    init(presenter: CreateMerchantTypePresentable,
                  authStream: AuthenticatedStream) {
        self.authStream = authStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    private var authStream: AuthenticatedStream?

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

// MARK: CreateMerchantTypeInteractable's members
extension CreateMerchantTypeInteractor: CreateMerchantTypeInteractable {
    func reloadListMerchant() {
        self.listener?.reloadListMerchant()
        
        self.listener?.createMerchantTypeMoveBack()
    }
    
    func createMerchantDetailMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
//    func upad
}

// MARK: CreateMerchantTypePresentableListener's members
extension CreateMerchantTypeInteractor: CreateMerchantTypePresentableListener {
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObserver()
    }
    
    var listCategoriesObserable: Observable<MerchantCategory> {
        return listCategoriesSubject.asObserver()
    }
    
    func getListCategories() {
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({
                    Requester.responseCacheDTO(decodeTo: VatoNetwork.OptionalMessageDTO<MerchantCategory>.self,
                                               using: VatoFoodApi.listCategory(authToken: $0, categoryId: nil, params: nil),
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
                            self?.listCategoriesSubject.onNext(result)
                        }
                    }
                    self?.presenter.checkShowEmptyView()
                    }, onError: {[weak self] (e) in
                        self?.errorSubject.onNext(.errorSystem(err: e))
                        self?.presenter.checkShowEmptyView()
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func backToMainMerchant() {
        self.listener?.createMerchantTypeMoveBack()
    }
    
    func createMerchantDetail(indexPath: IndexPath) {
        self.listCategoriesObserable.take(1).bind {[weak self] (category) in
            if let listCategory = category.children {
                self?.router?.routeToCreateMerchantDetail(category: listCategory[indexPath.row])
            }
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension CreateMerchantTypeInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
