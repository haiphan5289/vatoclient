//  File name   : BlockDriverInteractor.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol BlockDriverRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    
    func goToFindDriver()
    func goToDetailDriver(driver: BlockDriverInfo)
}

protocol BlockDriverPresentable: Presentable {
    var listener: BlockDriverPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BlockDriverListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func blockListMoveBack()
}

final class BlockDriverInteractor: PresentableInteractor<BlockDriverPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: BlockDriverRouting?
    weak var listener: BlockDriverListener?

    /// Class's constructor.
    override init(presenter: BlockDriverPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        getAllBlockDriver()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var blackListObs: PublishSubject<[BlockDriverInfo]> = PublishSubject.init()
}

// MARK: BlockDriverInteractable's members
extension BlockDriverInteractor: BlockDriverInteractable {
    func findClose() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func addClose() {
        router?.dismissCurrentRoute(completion: nil)
        getAllBlockDriver()
    }

    func goBackToList(type: TypeBlock) {
        if type == .remove {
            router?.dismissCurrentRoute(completion: nil)
            getAllBlockDriver()
        }
    }
    
    func detailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: BlockDriverPresentableListener's members
extension BlockDriverInteractor: BlockDriverPresentableListener {
    func moveBack() {
        listener?.blockListMoveBack()
    }
    
    func addBlockDriver() {
        router?.goToFindDriver()
    }
    
    func goToDetailDriver(driver: BlockDriverInfo) {
        router?.goToDetailDriver(driver: driver)
    }
    
    func getAllBlockDriver() {
        let userId = UserManager.instance.userId ?? 0
        let p = "https://api-dev.vato.vn/api/user/\(userId)/blacklist"
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[BlockDriverInfo]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                        //print(result.message ?? "")
                    } else {
                        if let r = d.data {
                            wSelf.blackListObs.onNext(r)
                        }
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    var blackListObser: Observable<[BlockDriverInfo]> {
        return self.blackListObs.asObserver()
    }
}

// MARK: Class's private methods
private extension BlockDriverInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}

struct BlockDriverInfo: Codable {
    var avatarUrl: String?
    var fullName: String?
    let id: Int64
    var phone: String
    var appVersion: String?
    var type: TypeBlock?
}

struct DDriverInfo: Codable {
    var avatar: String?
    var fullName: String?
    let id: Int64
    var firebaseId: String?
}


