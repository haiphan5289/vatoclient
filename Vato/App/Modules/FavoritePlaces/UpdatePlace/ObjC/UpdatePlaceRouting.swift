//
//  UpdatePlaceRouting.swift
//  Vato
//
//  Created by MacbookPro on 12/4/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import RIBs
import UIKit
import RxSwift

protocol UpdatePlaceRoutingListener {
    func getModel(model: AddressProtocol)
    func dismiss()
}

final class UpdatePlaceRouting: NSObject, LocationPickerListener, LocationPickerDependency, LocationRequestProtocol, Weakifiable {
    private var routing: LocationPickerRouting?
    var listener: UpdatePlaceRoutingListener?
    private lazy var disposeBag = DisposeBag()
    func pickerDismiss(currentAddress: AddressProtocol?) {
        self.listener?.dismiss()
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.validate(address: model).bind(onNext: weakify({ (new, wSelf) in
            wSelf.listener?.getModel(model: new)
        })).disposed(by: disposeBag)
    }
    var authenticatedStream: AuthenticatedStream = AuthenticatedStreamImpl()
    
    func presentViewController(model: PlaceModel, authenticated: AuthenticatedStream) -> UIViewController {
        var address: Address?
        if model.coordinate != kCLLocationCoordinate2DInvalid {
            address = Address(
                placeId: nil,
                coordinate: model.coordinate,
                name: model.getName(),
                thoroughfare: "",
                locality: "",
                subLocality:  "",
                administrativeArea: "",
                postalCode: "",
                country: "",
                lines: [],
                zoneId: 0, isOrigin: false, counter: 0, distance: nil, favoritePlaceID: Int64((model.typeId).rawValue))
        }

        let builder = LocationPickerBuilder(dependency: UpdatePlaceRoutingComponent(authenticate: authenticated))
        let r = builder.build(withListener: self,
                                      placeModel: address,
                                      searchType: .none,
                                      typeLocationPicker: .updatePlaceMode)
        defer {
            self.routing = r
        }
        r.interactable.activate()
        r.load()
        let vc = r.viewControllable.uiviewController
        return vc
    }
    
    func deactive() {
        self.routing?.interactable.deactivate()
        self.routing = nil
    }
}

protocol UpdatePlaceRoutingDependency: Dependency {
    var authenticated: AuthenticatedStream { get }
}
final class UpdatePlaceRoutingComponent: Component<EmptyComponent>, UpdatePlaceRoutingDependency {
    var authenticated: AuthenticatedStream
    
    init(authenticate: AuthenticatedStream) {
        self.authenticated = authenticate
        super.init(dependency: EmptyComponent())
    }
}

