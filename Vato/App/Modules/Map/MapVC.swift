//  File name   : MapVC.swift
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
import RxSwift
import UIKit

protocol MapPresentableListener: class {
    func displayToHome()
}

final class MapVC: UIViewController, MapPresentable, MapViewControllable {
    /// Class's public properties.
    weak var listener: MapPresentableListener?

    private(set) lazy var mapView: GMSMapView = {
        let map = GMSMapView()
        map.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(10.7664067, 106.6935349)))
        map.setMinZoom(16, maxZoom: 20)
        return map
    }()

    deinit {
        debugPrint("\(#function)")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isPresented else {
            return
        }
        isPresented = true
        listener?.displayToHome()

        // Check location permission
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
//            break
//        default:
//            let cancelAction = AlertAction(style: .cancel, title: Text.later.localizedText, handler: {})
//            let acceptAction = AlertAction(style: .default, title: Text.settings.localizedText, handler: {
//                guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else {
//                    return
//                }
//                UIApplication.shared.openURL(settingsURL)
//            })
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                AlertVC.show(on: self,
//                             title: Text.turnOnLocationFeature.localizedText,
//                             message: Text.turnOnLocationFeatureDescription.localizedText,
//                             from: [cancelAction, acceptAction],
//                             orderType: .horizontal)
//            }
//        }
    }

    /// Class's private properties.
    private var isPresented = false
    private let disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension MapVC {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: View's key pressed event handlers
extension MapVC {
    @IBAction func handleButtonOnPressed(_ sender: Any) {}
}

// MARK: Class's public methods
extension MapVC {
    func moveCamera(to location: CLLocationCoordinate2D) {
        mapView.animate(toLocation: location)
    }
}

// MARK: Class's private methods
private extension MapVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if
            let nightURL = Bundle.main.url(forResource: "custom-map", withExtension: "json"),
            let style = try? GMSMapStyle(contentsOfFileURL: nightURL) {
            mapView.mapStyle = style
            mapView.isBuildingsEnabled = false
            mapView.settings.indoorPicker = false
            mapView.settings.rotateGestures = false
        }
    }

    private func setupRX() {
    }
}
