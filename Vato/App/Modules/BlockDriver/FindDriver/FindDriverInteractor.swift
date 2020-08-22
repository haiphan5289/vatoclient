//  File name   : FindDriverInteractor.swift
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


protocol FindDriverRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func goToBlock(driver: BlockDriverInfo)
}

protocol FindDriverPresentable: Presentable {
    var listener: FindDriverPresentableListener? { get set }
    func validateBtnNext(isValidate: Bool)
    func showAlertFail(message: String)
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FindDriverListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    //    func close()
    func findClose()
    func addClose()
}

final class FindDriverInteractor: PresentableInteractor<FindDriverPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: FindDriverRouting?
    weak var listener: FindDriverListener?
    
    /// Class's constructor.
    override init(presenter: FindDriverPresentable) {
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

// MARK: FindDriverInteractable's members
extension FindDriverInteractor: FindDriverInteractable {
    func detailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func goBackToList(type: TypeBlock) {
        type == .add ? listener?.addClose() : detailMoveBack()
    }
}

// MARK: FindDriverPresentableListener's members
extension FindDriverInteractor: FindDriverPresentableListener {
    func validPhone(phoneNumber: String) {
        var isValidate: Bool
        let phoneUtil = NBPhoneNumberUtil.sharedInstance()
        
        do {
            let myNumber = try phoneUtil?.parse(phoneNumber, defaultRegion: "VN")
            var national = try phoneUtil?.format(myNumber, numberFormat: .NATIONAL)
            national = national?.replacingOccurrences(of:" ", with: "")
            if national?.count ?? 0 > 10 {
                isValidate = false
                return
            }
            isValidate = phoneUtil?.isValidNumber(myNumber) ?? false
        }
        catch let error as NSError {
            print(error.localizedDescription)
            isValidate = false
        }
        self.presenter.validateBtnNext(isValidate: isValidate)
    }
    
    func close() {
        listener?.findClose()
    }
    
    func goContinue(phone: String) {
        var params = JSON()
        params["phoneNumber"] = phone
        
        let networkRouter = VatoAPIRouter.customPath(authToken:"", path: "user/check_info", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        
        network.request(using: networkRouter,
                        decodeTo: OptionalMessageDTO<DDriverInfo>.self)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if let data = d.data {
                        let d = BlockDriverInfo(avatarUrl: data.avatar, fullName: data.fullName, id: data.id, phone: phone, appVersion: nil, type: .add)
                            wSelf.router?.goToBlock(driver: d)
                    } else {
                            wSelf.presenter.showAlertFail(message: d.message ?? "")
                    }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
        
    }
    
}

// MARK: Class's private methods
private extension FindDriverInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}



