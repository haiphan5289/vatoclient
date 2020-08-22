//  File name   : FillInformationInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol FillInformationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToContact()
    func routeToSearchAddress(model: AddressProtocol?, searchType: SearchType)
    func routeToPinAddress(model: AddressProtocol?, isOrigin: Bool)
    func routeToPickTime(token: Observable<String>)
}

protocol FillInformationPresentable: Presentable {
    var listener: FillInformationPresentableListener? { get set }
    func update(type: FillInformationCellType, value: Any?)
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FillInformationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func fillInformationMoveBack()
    func fillInformation(new: DeliveryInputInformation, serviceType: DeliveryServiceType)
}

final class FillInformationInteractor: PresentableInteractor<FillInformationPresentable>, Weakifiable {
    /// Class's public properties.
    weak var router: FillInformationRouting?
    weak var listener: FillInformationListener?
    private let old: DeliveryInputInformation
    private let new: DeliveryInputInformation
    internal let serviceType: DeliveryServiceType
    private var deliveryDateTime: DeliveryDateTime?
    
    /// Class's constructor.
    init(presenter: FillInformationPresentable,
         old: DeliveryInputInformation,
         profileStream: MutableProfileStream,
         bookingPoints: BookingStream,
         serviceType: DeliveryServiceType,
         authenticated: AuthenticatedStream) {
        
        self.authenticated = authenticated
        self.bookingPoints = bookingPoints
        self.serviceType = serviceType
        self.old = old
        new = old.copy()
        self.profileStream = profileStream
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
    private let profileStream: MutableProfileStream
    private let bookingPoints: BookingStream
    private let authenticated: AuthenticatedStream
}

// MARK: FillInformationInteractable's members
extension FillInformationInteractor: FillInformationInteractable {
    
    func update(model: DeliveryDateTime?) {
        self.deliveryDateTime = model
        self.presenter.update(type: .time, value: model?.string())
    }
    
    func pinAddressDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinDidselect(model: MapModel.Place) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            let location = CLLocationCoordinate2D(latitude: model.location?.lat ?? 0, longitude: model.location?.lon ?? 0)
            let address = Address(
                placeId: nil,
                coordinate: location,
                name: model.primaryName ?? "",
                thoroughfare: "",
                locality: "",
                subLocality: model.address ?? "",
                administrativeArea: "",
                postalCode: "",
                country: "",
                lines: [],
                zoneId: 0,
                isOrigin: false,
                counter: 0,
                distance: nil,
                favoritePlaceID: 0)

            self?.new.originalDestination = address
            self?.presenter.update(type: .address, value: address)
        })
    }
    
    func update(name: String?) {
        guard let name = name else { return }
        self.presenter.update(type: .name, value: name)
    }
    
    func update(phone: String?) {
        guard let p = phone else { return }
        self.presenter.update(type: .phone, value: p)
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let currentAddress = currentAddress else { return }
            self?.update(model: currentAddress)
        })
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.update(model: model)
        })
    }
    
    private func update(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            wSelf.new.originalDestination = new
            wSelf.presenter.update(type: .address, value: new)
        }))
    }
}

// MARK: FillInformationPresentableListener's members
extension FillInformationInteractor: FillInformationPresentableListener, LocationRequestProtocol {
    
    func fillInformationMe() {
        profileStream.client.take(1).bind(onNext: weakify({ (client, wSelf) in
            let user = client.user
            wSelf.presenter.update(type: .name, value: user?.fullName)
            wSelf.presenter.update(type: .phone, value: user?.phone)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func udpateReceiver(phone: String?) {
        profileStream.client.take(1).bind(onNext: weakify({ (client, wSelf) in
            let user = client.user
            let isMe = phone == user?.phone
            wSelf.presenter.update(type: .chooseReceiver, value: isMe)
        })).disposeOnDeactivate(interactor: self)
    }
    
    var newInfo: DeliveryInputInformation {
        return new
    }
    
    var currentInfo: DeliveryInputInformation {
        return old
    }
    
    func routeToContact() {
        router?.routeToContact()
    }
    
    func routeToChangeAdress() {
        if let location = self.new.originalDestination {
            self.router?.routeToSearchAddress(model: location, searchType: .express(origin: true, fillInfo: true))
        } else {
            bookingPoints.booking.take(1).timeout(.milliseconds(300), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](b) in
                self?.router?.routeToSearchAddress(model: b.destinationAddress1, searchType: .express(origin: false, fillInfo: b.destinationAddress1 != nil))
            }, onError: { [weak self](e) in
                let `default` = MapInteractor.Config.defaultMarker
                self?.router?.routeToSearchAddress(model: `default`.address, searchType: .express(origin: false, fillInfo: false))
            }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func updateInformation() {
        self.listener?.fillInformation(new: new, serviceType: self.serviceType)
    }
    
    func moveBack() {
        listener?.fillInformationMoveBack()
    }
    
    func routeToPinAdress() {
        let isOrigin  = (new.type == .sender) ? true : false

        if let location = self.new.originalDestination {
            self.router?.routeToPinAddress(model: location, isOrigin: isOrigin)
        } else {
            bookingPoints.booking.take(1).timeout(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](b) in
                self?.router?.routeToPinAddress(model: b.originAddress, isOrigin: isOrigin)
                }, onError: { [weak self](e) in
                    let `default` = MapInteractor.Config.defaultMarker
                    self?.router?.routeToPinAddress(model: `default`.address, isOrigin: isOrigin)
            }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func routeToPickTime() {
        router?.routeToPickTime(token: self.authenticated.firebaseAuthToken)
    }
}

// MARK: Class's private methods
private extension FillInformationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        
        DispatchQueue.main.async {
            if self.old.originalDestination == nil {
                self.routeToChangeAdress()
            }
        }
    }
}
