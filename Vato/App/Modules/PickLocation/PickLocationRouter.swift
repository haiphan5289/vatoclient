//  File name   : PickLocationRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import GoogleMaps
import RIBs
import RxCocoa
import RxSwift
import SnapKit

protocol PickLocationInteractable: Interactable {
    var router: PickLocationRouting? { get set }
    var listener: PickLocationListener? { get set }

    var address: Observable<String> { get }
    var location: Observable<CLLocationCoordinate2D> { get }

    func backToSearchLocation()
    func handlerConfirmPickLocation()

    func lookupCurrentAddress()
    func lookupAddress(for: CLLocationCoordinate2D)
}

protocol PickLocationViewControllable: ViewControllable {
    func bind(marker: UIImageView)
    func generatePickLocationUI(for locationType: LocationType) -> (UIView, UILabel, UIButton, UIButton, UIButton)
}

final class PickLocationRouter: Router<PickLocationInteractable>, PickLocationRouting, NetworkTrackingProtocol {
    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: PickLocationInteractable, viewController: PickLocationViewControllable, mapView: GMSMapView, bookingState: BookingState) {
        self.viewController = viewController
        self.mapView = mapView
        self.bookingState = bookingState

        switch bookingState {
        case .pickLocation(let locationType), .editPickLocation(let locationType):
            self.locationType = locationType

        default:
            self.locationType = .origin
        }

        super.init(interactor: interactor)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
        UIApplication.setStatusBar(using: .lightContent)

        // Listen to map view event
        proxy = Proxy(with: true)
        mapView.delegate = proxy
        mapView.isMyLocationEnabled = true

        // Bind UI
        let controls = viewController.generatePickLocationUI(for: locationType)
        viewController.bind(marker: markerImageView)

        barView = controls.0
        addressLabel = controls.1
        backButton = controls.2
        confirmButton = controls.3
        currentLocationButton = controls.4

        backButton?.addTarget(self, action: #selector(PickLocationRouter.handleBackButtonOnPressed(_:)), for: .touchUpInside)
        confirmButton?.addTarget(self, action: #selector(PickLocationRouter.handleConfirmButtonOnPressed(_:)), for: .touchUpInside)
        currentLocationButton?.addTarget(self, action: #selector(PickLocationRouter.handleCurrentLocationButtonOnPressed(_:)), for: .touchUpInside)

        // Binding event
        setupRX()
    }

    func cleanupViews() {
        mapView.isMyLocationEnabled = false
        UIApplication.setStatusBar(using: .default)

        backButton?.removeTarget(self, action: #selector(PickLocationRouter.handleBackButtonOnPressed(_:)), for: .allEvents)
        confirmButton?.removeTarget(self, action: #selector(PickLocationRouter.handleConfirmButtonOnPressed(_:)), for: .allEvents)
        currentLocationButton?.removeTarget(self, action: #selector(PickLocationRouter.handleCurrentLocationButtonOnPressed(_:)), for: .allEvents)

        barView?.removeFromSuperview()
        markerImageView.removeFromSuperview()
        confirmButton?.removeFromSuperview()
        currentLocationButton?.removeFromSuperview()
    }

    func enableConfirmButton() {
        confirmButton?.isEnabled = true
    }

    @objc func handleBackButtonOnPressed(_ sender: Any) {
        interactor.backToSearchLocation()
    }

    @objc func handleConfirmButtonOnPressed(_ sender: Any) {
        interactor.handlerConfirmPickLocation()
    }

    @objc func handleCurrentLocationButtonOnPressed(_ sender: Any) {
        if let coordinate = VatoLocationManager.shared.location?.coordinate {
            interactor.lookupCurrentAddress()
            mapView.animate(toLocation: coordinate)
        }
    }

    /// Class's private properties
    private let viewController: PickLocationViewControllable
    private let mapView: GMSMapView
    private let bookingState: BookingState
    private let locationType: LocationType

    private let disposeBag = DisposeBag()

    private var barView: UIView?
    private var addressLabel: UILabel?
    private var backButton: UIButton?
    private var confirmButton: UIButton?
    private var currentLocationButton: UIButton?

    private lazy var proxy = Proxy()
    private lazy var markerImageView: UIImageView = {
        if locationType == .origin {
            return UIImageView(image: #imageLiteral(resourceName: "ic_origin_marker"))
        } else {
            return UIImageView(image: #imageLiteral(resourceName: "ic_destination_marker"))
        }
    }()
}

// MARK: Class's private methods
private extension PickLocationRouter {
    private func setupRX() {
        guard let i = interactable as? Interactor else {
            return
        }

        let o = interactor.address
            .map { $0 == Text.unnamedRoad.localizedText ? Text.currentPin.localizedText : $0 }
            .observeOn(MainScheduler.asyncInstance)

        o.subscribe(onNext: { [weak self] newAddress in
            self?.addressLabel?.text = newAddress
        })
        .disposeOnDeactivate(interactor: i)

//        _ = o.skip(1).take(1).subscribe(onNext: { [weak self] (_) in
//            self?.enableConfirmButton()
//        })

        _ = interactor.location
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coordinate in
                let zoom = self?.proxy.zoom ?? 17

                let update = GMSCameraUpdate.setTarget(coordinate, zoom: zoom)
                self?.mapView.animate(with: update)

                self?.hideCurrentLocationButton(coordinate: coordinate)
            })
//            .disposeOnDeactivate(interactor: i)

        interactor.location
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coordinate in
                self?.hideCurrentLocationButton(coordinate: coordinate)
            })
            .disposeOnDeactivate(interactor: i)

        proxy.movingSubject
            .map { (isMoving) -> String in
                if isMoving {
                    return "\(Text.search.localizedText.capitalized)..."
                }
                return ""
            }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                self?.addressLabel?.text = text
            })
            .disposeOnDeactivate(interactor: i)

        proxy.locationSubject
            .subscribe(onNext: { [weak self] location in
                self?.lookupAddress(for: location)
            })
            .disposeOnDeactivate(interactor: i)
    }

    private func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    wSelf.interactor.lookupAddress(for: coordinate)
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }

    private func hideCurrentLocationButton(coordinate: CLLocationCoordinate2D) {
        guard let currentLocation = VatoLocationManager.shared.location else {
            return
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: currentLocation)

        if distance > 50.0 {
            currentLocationButton?.isHidden = false
            currentLocationButton?.alpha = 1.0
        } else {
            currentLocationButton?.alpha = 0.0
            currentLocationButton?.isHidden = true
        }
    }
}

// MARK: GMSMapViewDelegate's members
fileprivate class Proxy: NSObject, GMSMapViewDelegate {
    /// Class's public properties.
    fileprivate let locationSubject = ReplaySubject<CLLocationCoordinate2D>.create(bufferSize: 1)
    fileprivate let movingSubject = ReplaySubject<Bool>.create(bufferSize: 1)

    fileprivate(set) var zoom: Float = 17

    /// Class's constructors
    fileprivate init(with animation: Bool = false) {
        isAnimation = animation
        super.init()
    }

    fileprivate func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        defer { isAnimation = !gesture }

        guard gesture else {
            return
        }
        movingSubject.on(.next(true))
    }

    fileprivate func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        defer {
            isAnimation = false
            zoom = position.zoom
        }

        guard !isAnimation else {
            return
        }
        movingSubject.on(.next(false))
        locationSubject.on(.next(position.target))
    }

    /// Class's private properties.
    private var isAnimation: Bool
}
