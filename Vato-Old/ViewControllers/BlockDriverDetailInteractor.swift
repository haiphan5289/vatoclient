//  File name   : BlockDriverDetailInteractor.swift
//
//  Author      : admin
//  Created date: 6/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol BlockDriverDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BlockDriverDetailPresentable: Presentable {
    var listener: BlockDriverDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertFail(message: String?)
}

protocol BlockDriverDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func detailMoveBack()
    func goBackToList(type: TypeBlock)
}

final class BlockDriverDetailInteractor: PresentableInteractor<BlockDriverDetailPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: BlockDriverDetailRouting?
    weak var listener: BlockDriverDetailListener?

    /// Class's constructor.
    init(presenter: BlockDriverDetailPresentable, driver: BlockDriverInfo) {
        self.driver = driver
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        mDriver = driver
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var driver: BlockDriverInfo
    @Replay(queue: MainScheduler.asyncInstance) private var mDriver: BlockDriverInfo
}

// MARK: BlockDriverDetailInteractable's members
extension BlockDriverDetailInteractor: BlockDriverDetailInteractable {
}

// MARK: BlockDriverDetailPresentableListener's members
extension BlockDriverDetailInteractor: BlockDriverDetailPresentableListener {
    var driverObs: Observable<BlockDriverInfo> {
        return self.$mDriver
    }

    func moveBack() {
        listener?.detailMoveBack()
    }
    
    func addBlockDriver(driver: BlockDriverInfo?) {
        var params = [String: Any]()
        params["userId"] = driver?.id ?? 0
        let router = VatoAPIRouter.customPath(authToken: "", path: "user/add_driver_to_blacklist", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<Bool>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                        wSelf.presenter.showAlertFail(message: d.message)
                    } else {
                        if let data = d.data, data {
                            wSelf.listener?.goBackToList(type: TypeBlock.add)
                        }
                    }
                case .failure(let e):
                    wSelf.presenter.showAlertFail(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func removeBlockDriver(driver: BlockDriverInfo?) {
        var params = [String: Any]()
        params["userId"] = driver?.id ?? 0
        let router = VatoAPIRouter.customPath(authToken: "", path: "user/remove_driver_from_blacklist", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<Bool>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                        wSelf.presenter.showAlertFail(message: d.message)
                    } else {
                        if let data = d.data, data {
                            wSelf.listener?.goBackToList(type: TypeBlock.remove)
                        }
                    }
                case .failure(let e):
                    wSelf.presenter.showAlertFail(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension BlockDriverDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
