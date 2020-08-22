//  File name   : CarContractInteractor.swift
//
//  Author      : an.nguyen
//  Created date: 8/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol CarContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToOrder()
    func routeToMap(type: SearchType, address: AddressProtocol?)
    func routeToPickTime(model: DateTime?)
}

protocol CarContractPresentable: Presentable {
    var listener: CarContractPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    
    func update(model: AddressProtocol, type: FillContractCellType)
    func update(cellType: FillContractCellType, value: Any?)
}

protocol CarContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBack()
}

final class CarContractInteractor: PresentableInteractor<CarContractPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: CarContractRouting?
    weak var listener: CarContractListener?

    /// Class's constructor.
    override init(presenter: CarContractPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        getAllOptions()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    var pickType: FillContractCellType = .origin
    var crrDate: DateTime?
    private var optionsSubject: PublishSubject<OptionContract> = PublishSubject.init()
}

// MARK: CarContractInteractable's members
extension CarContractInteractor: CarContractInteractable {
    var interval: TimeInterval {
        return 0.0
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            self?.presenter.update(model: model, type: wSelf.pickType)
        })
    }
    
    func moveBackCarContract() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func selectTime(model: DateTime?) {
        guard let model = model else { return }
        let dateStr = "\(model.timeDescription) \(model.dateDescription)"
        crrDate = model
        self.presenter.update(cellType: .departure, value: dateStr)
    }
    
    func getAllOptions() {
        var params = [String: Any]()
        params["all"] = true
        let router = VatoAPIRouter.customPath(authToken: "", path: "rentalcar/orders/options", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<OptionContract>.self,
                        method: .get)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                    } else {
                        if let r = d.data {
                            wSelf.optionsSubject.onNext(r)
                        }
                    }
                case .failure(let e):
                    break
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func submitOrder(contract: CarContract) {
        var params = [String: Any]()
        params["pickup"] = contract.pickup
        params["pickup_time"] = contract.pickup_time
        params["drop"] = contract.drop
        params["drop_time"] = contract.drop_time
        params["trip_type"] = contract.trip_type
        params["num_of_people"] = contract.num_of_people
        params["num_of_seat"] = contract.num_of_seat
        params["vehicle_rank"] = contract.vehicle_rank
        params["driver_gender"] = contract.driver_gender
        params["require_bill"] = contract.require_bill
        params["note"] = contract.note
        params["other_grant"] = contract.other_grant
        params["other_name"] = contract.other_name
        params["other_phone"] = contract.other_phone
        params["other_email"] = contract.other_email
        let router = VatoAPIRouter.customPath(authToken: "", path: "rentalcar/orders", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<OptionContract>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail {
                    } else {
                        if let r = d.data {
                            wSelf.goToOrder()
                        }
                    }
                case .failure(let e):
                    break
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    var optionObser: Observable<OptionContract> {
        return self.optionsSubject.asObserver()
    }

}

// MARK: CarContractPresentableListener's members
extension CarContractInteractor: CarContractPresentableListener {
    func moveBack() {
        listener?.moveBack()
    }
    
    func goToOrder() {
        self.router?.routeToOrder()
    }
    
    func routeToMap(type: FillContractCellType) {
        let typeSearch: SearchType = type == .origin ? .booking(origin: true, placeHolder: "Đón bạn tại", icon: UIImage(named: "ic_origin"), fillInfo: false) : .booking(origin: false, placeHolder: "Đưa bạn đến", icon: UIImage(named: "ic_destination"), fillInfo: false)
        pickType = type
        self.router?.routeToMap(type: typeSearch, address: nil)
    }
    
    func routeToPickTime() {
        router?.routeToPickTime(model: crrDate)
    }
    
    
}

// MARK: Class's private methods
private extension CarContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    
}
