//  File name   : FoodMapVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import FwiCore
import FwiCoreRX
import SnapKit

protocol FoodMapPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var item: FoodExploreItem { get }
    func foodMapMoveBack()
}

final class FoodMapVC: UIViewController, FoodMapPresentable, FoodMapViewControllable, DisplayDistanceProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FoodMapPresentableListener?
    @IBOutlet var lblNameStore: UILabel?
    @IBOutlet var lblAddress: UILabel?
    @IBOutlet var lblCategory: UILabel?
    @IBOutlet var lblDistance: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblOpen: UILabel?
    @IBOutlet var lblTitleTime: UILabel?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var btnBack: UIButton?
    @IBOutlet var mapContainerView: UIView!
    
    @IBOutlet var viewDiscount: UIStackView?
    @IBOutlet var lblDiscount: UILabel?
    
    private(set) lazy var mapView: GMSMapView = {
        let map = GMSMapView()
        map.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(10.7664067, 106.6935349)))
        map.setMinZoom(16, maxZoom: 20)
        return map
    }()
    private lazy var disposeBag = DisposeBag()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        localize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = mapContainerView.bounds
        let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.frame = rect
        shape.fillColor = UIColor.blue.cgColor
        shape.path = benzier.cgPath
        mapContainerView.layer.mask = shape
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension FoodMapVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FoodMapVC {
}

// MARK: Class's private methods
private extension FoodMapVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    func setupRX() {
        btnBack?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.foodMapMoveBack()
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        if
            let nightURL = Bundle.main.url(forResource: "custom-map", withExtension: "json"),
            let style = try? GMSMapStyle(contentsOfFileURL: nightURL) {
            mapView.mapStyle = style
            mapView.isBuildingsEnabled = false
            mapView.settings.indoorPicker = false
            mapView.settings.rotateGestures = false
        }
        
        mapView >>> mapContainerView >>> {
            $0.isUserInteractionEnabled = false
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let imageView = UIImageView(image: UIImage(named: "ic_store_marker"))
        imageView.contentMode = .scaleAspectFit
        
        imageView >>> mapContainerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 30, height: 40))
                make.center.equalToSuperview()
            })
        }
        
        let item = listener?.item
        if let coor = item?.coordinate {
            DispatchQueue.main.async {
                self.mapView.moveCamera(.setTarget(coor, zoom: 17))
            }
        }
        lblNameStore?.text = item?.name
        lblAddress?.text = item?.address
        let working = item?.workingHours
        FoodWeekDayType.allCases.forEach { (type) in
            let view = FoodWorkingHourView.loadXib()
            view.setupDisplay(item: working?.daily?[type], range: working?.range)
            stackView?.addArrangedSubview(view)
        }
        displayDistance(item: item)
        lblCategory?.text = item?.descriptionCat
        guard let today = FoodWeekDayType.today() else { return }
        if let time = item?.workingHours?.daily?[today] {
            lblOpen?.text = time.openText
            lblOpen?.textColor = time.color
        } else {
            lblOpen?.text = "--"
            lblOpen?.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
    }
}
