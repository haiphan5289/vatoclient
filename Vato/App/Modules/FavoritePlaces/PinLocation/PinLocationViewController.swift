//
//  PinLocationViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork
import GoogleMaps

class PinLocationViewController: UIViewController {
    var didSelect: ((MapModel.PlaceDetail) -> Void)?
    
    @IBOutlet weak var saveAddressButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    private var searchDisposable: Disposable?
    private var placeDetail: MapModel.PlaceDetail?
    var placeDetailSubject = ReplaySubject<MapModel.PlaceDetail?>.create(bufferSize: 1)
    
    @IBOutlet weak var constraintTopHeader: NSLayoutConstraint!
    
    // MARK: - property
    @IBOutlet weak var backButton: UIButton!
    
    private lazy var disposeBag = DisposeBag()
    
    
    var viewModel: PinLocationVM!
    
    convenience init(viewModel: PinLocationVM) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveAddressButton.setTitle(Text.confirm.localizedText, for: .normal)
        setupView()
        setRX()
        mapView.delegate = self
        self.placeDetailSubject.onNext(nil)
        
        // fix bug in iphone 5 ios 10.3.3 (header overwrite to status bar)
        DispatchQueue.main.async {
            self.constraintTopHeader.constant = UIApplication.shared.statusBarFrame.height
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private method
    
    func setupView() {
        self.saveAddressButton.setTitle(Text.confirm.localizedText, for: .normal)
        let backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.view.backgroundColor = backgroundColor
        
        if let nightURL = Bundle.main.url(forResource: "custom-map", withExtension: "json"),
            let style = try? GMSMapStyle(contentsOfFileURL: nightURL) {
            mapView.mapStyle = style
        }
        
        mapView.isBuildingsEnabled = false
        mapView.settings.indoorPicker = false
        mapView.settings.rotateGestures = false
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.setMinZoom(1, maxZoom: 20)
        
        if let coordinate = VatoLocationManager.shared.location?.coordinate {
            mapView.animate(with: GMSCameraUpdate.setTarget(coordinate))
            mapView.animate(toZoom: 18.0)
        }
        
        var bottomAreaInsets: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomAreaInsets = window?.safeAreaInsets.bottom ?? 0
        }
        
        bottomAreaInsets = bottomAreaInsets + 78
         mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: bottomAreaInsets, right: 0)
    }
    
    func setRX(){
        self.backButton.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        self.saveAddressButton.rx.tap.bind { [weak self] in
            if let placeDetail = self?.placeDetail {
                self?.didSelect?(placeDetail)
            }
            }.disposed(by: disposeBag)
    
        self.currentLocationButton.rx.tap.bind { [weak self] in
            if let coordinate = VatoLocationManager.shared.location?.coordinate {
                self?.mapView.animate(toLocation: coordinate)
            }
            }.disposed(by: disposeBag)
        
        self.placeDetailSubject.subscribe(onNext: { [weak self] model in
            self?.placeDetail = model
            if let model = model {
                self?.addressLabel.text = model.fullAddress
                self?.saveAddressButton.isUserInteractionEnabled = true
                self?.saveAddressButton.alpha = 1
            } else {
                self?.addressLabel.text = Text.search.localizedText + "..."
                self?.saveAddressButton.isUserInteractionEnabled = false
                self?.saveAddressButton.alpha = 0.5
            }
        }).disposed(by: disposeBag)
    }
    
    func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        searchDisposable?.dispose()
        searchDisposable = FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap{ MapAPI.geocoding(authToken: $0, lat: coordinate.latitude, lng: coordinate.longitude) }
            .timeout(.seconds(30), scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
                self.placeDetailSubject.onNext(result)
            })
    }
}

extension PinLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.placeDetailSubject.onNext(nil)
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.lookupAddress(for: position.target)
    }
}
