//  File name   : ShoppingFillInformationInteractor.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FirebaseFirestore

struct SupplyConfig: Codable {
    struct Config {
        static let defaultMaxEstimatedPrice = 3000000
    }
    var maxEstimatedPrice: Int?
}


protocol ShoppingFillInformationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToChangeAdress(model: AddressProtocol?, searchType: SearchType)
    func routeToPinAddress(model: AddressProtocol?, isOrigin: Bool)
    func routeToContact()
}

protocol ShoppingFillInformationPresentable: Presentable {
    var listener: ShoppingFillInformationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func update(type: ShoppingFillInformationCellType, value: Any?)

}

protocol ShoppingFillInformationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func shoppingFillInformationMoveBack()
    func fillInformation(new: DeliveryInputInformation)

}

final class ShoppingFillInformationInteractor: PresentableInteractor<ShoppingFillInformationPresentable>, Weakifiable {
    /// Class's public properties.
    weak var router: ShoppingFillInformationRouting?
    weak var listener: ShoppingFillInformationListener?

    private let new: DeliveryInputInformation
    private let old: DeliveryInputInformation
    
    private let profileStream: MutableProfileStream
    private let bookingPoints: BookingStream
    private let authenticated: AuthenticatedStream

    /// Class's constructor.
    init(presenter: ShoppingFillInformationPresentable,
         old: DeliveryInputInformation,
         profileStream: MutableProfileStream,
         bookingPoints: BookingStream,
         authenticated: AuthenticatedStream) {
        self.old = old
        new = old.copy()
        self.profileStream = profileStream
        self.bookingPoints = bookingPoints
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        self.eSupplyConfig = SupplyConfig(maxEstimatedPrice: SupplyConfig.Config.defaultMaxEstimatedPrice)
        self.getSupplyConfig()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    @Replay(queue: MainScheduler.asyncInstance) private var eSupplyConfig: SupplyConfig
}

// MARK: ShoppingFillInformationInteractable's members
extension ShoppingFillInformationInteractor: ShoppingFillInformationInteractable {
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        self.router?.dismissCurrentRoute(completion: nil)

    }
    
    private func update(model: AddressProtocol) {
        self.updateAddress(model: model, update: weakify({ (new, wSelf) in
            wSelf.new.originalDestination = new
            wSelf.presenter.update(type: .address, value: new)
        }))
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.update(model: model)
        })
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
                zoneId: 0, isOrigin: false,
                counter: 0,
                distance: nil,
                favoritePlaceID: 0)

            self?.new.originalDestination = address
            self?.presenter.update(type: .address, value: address)

        })
    }
    
}

// MARK: ShoppingFillInformationPresentableListener's members
extension ShoppingFillInformationInteractor: ShoppingFillInformationPresentableListener, LocationRequestProtocol {
    
    var newInfo: DeliveryInputInformation {
        return new
    }
    
    var supplyConfig: Observable<SupplyConfig> {
        return $eSupplyConfig
    }
    
    var currentInfo: DeliveryInputInformation {
        return old
    }
    
    
    func update(name: String?) {
        guard let name = name else { return }
        self.presenter.update(type: .name, value: name)
    }
    
    func update(phone: String?) {
        guard let p = phone else { return }
        self.presenter.update(type: .phone, value: p)
    }
    
    
    func routeToChangeAddress() {
        let searchType: SearchType = .shopping(origin: true)
        if let location = self.new.originalDestination {
            self.router?.routeToChangeAdress(model: location, searchType: searchType)
        } else {
            bookingPoints.booking.take(1).timeout(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](b) in
                self?.router?.routeToChangeAdress(model: b.destinationAddress1, searchType: searchType)
            }, onError: { [weak self](e) in
                let `default` = MapInteractor.Config.defaultMarker
                self?.router?.routeToChangeAdress(model: `default`.address, searchType: searchType)
            }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func updateInformation() {
        self.listener?.fillInformation(new: new)
    }
    
    func routeToContact() {
        router?.routeToContact()
    }
    
    func routeToPinAdress() {
        if let location = self.new.originalDestination {
            self.router?.routeToPinAddress(model: location, isOrigin: false)
        } else {
            bookingPoints.booking.take(1).timeout(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](b) in
                self?.router?.routeToPinAddress(model: b.originAddress, isOrigin: false)
                }, onError: { [weak self](e) in
                    let `default` = MapInteractor.Config.defaultMarker
                    self?.router?.routeToPinAddress(model: `default`.address, isOrigin: false)
            }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func moveBack() {
        self.listener?.shoppingFillInformationMoveBack()
    }
    
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
    
    func getSupplyConfig() {
        let documentRef = Firestore.firestore().collection("ConfigData").document("Client").collection("Supply")
        documentRef.getDocuments { [weak self] (snapshot, error) in
            guard let wSelf = self else { return }
            guard let snapshot = snapshot else {
                print("Error \(error!)")
                return
            }
            
            if let document = snapshot.documents.first {
                let maxEstimatedPrice = document.get("maxEstimatedPrice") as? Int
                var config = SupplyConfig()
                config.maxEstimatedPrice = maxEstimatedPrice
                wSelf.eSupplyConfig = config
            }
        }
    }
    
}

// MARK: Class's private methods
private extension ShoppingFillInformationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        DispatchQueue.main.async {
            if self.old.originalDestination == nil {
                self.routeToChangeAddress()
            }
        }
    }
}
