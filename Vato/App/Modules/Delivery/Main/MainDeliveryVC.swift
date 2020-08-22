//  File name   : MainDeliveryVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
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
import Eureka

enum DeliveryServiceType: String {
    case URBAN_DELIVERY
    case DOMESTIC_DELIVERY
}

/// Description
protocol MainDeliveryPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var sender: Observable<DestinationDisplayProtocol> { get }
    var receiver: Observable<DestinationDisplayProtocol> { get }
    var ready: Observable<Bool> { get }
    var routeTrip: Observable<RouteTrip> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var listVehicle: Observable<[DeliveryVehicle]> { get }
    
    var domesticReceivers: Observable<[DestinationDisplayProtocol]> { get }
    
    func inputInformation(_ type: DeliveryDisplayType, serviceType: DeliveryServiceType, item: DeliveryInputInformation?)

    func book()
    func selectOtherDeliveryOption(_ option: String)
    func moveBack()
//    func moveToLocationPicker()
    func removeReceiverIfNeed(type: DeliveryDisplayType)
    func moveToPinLocation()
    func removeDomesticItem(item: DeliveryInputInformation?)
    func routeToDeliverySuccess()
}

final class MainDeliveryVC: FormViewController, MainDeliveryPresentable, MainDeliveryViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let DeliveryCellIdentifier = "DeliveryCellIdentifier"
        struct Note {
            static let handDelivery = Text.handDelivery.localizedText
            static let bigSizeDelivery = Text.pakageSizeBig.localizedText
            static let fastDelivery = Text.fastDelivery.localizedText
        }
        static let TableHeaderHeight: CGFloat = 140.0
    }
    
    /// Class's public properties.
    weak var listener: MainDeliveryPresentableListener?
    lazy var disposeBag = DisposeBag()
    private lazy var senderView = DestinationView(frame: .zero)
    private lazy var receiverView = DestinationView(frame: .zero)
    private lazy var containerEstimateView = UIView(frame: .zero)
    private var btnNext: UIButton?
    private weak var bookView: MainDeliveryBookingView?
    
    private lazy var lblDistance = UILabel(frame: .zero)
    private lazy var lblTime = UILabel(frame: .zero)
    
    private lazy var headerContentView = UIView(frame: .zero)

    private lazy var headerView: VatoLocationHeaderView = VatoLocationHeaderView(frame: .zero)
    private lazy var deliveryTypeView: DeliveryTypeHeaderView = DeliveryTypeHeaderView.loadXib()
    private lazy var sourceBanner: ReplaySubject<[BannerProtocol]> = ReplaySubject.create(bufferSize: 1)
    private lazy var footerView: FoodBannerView = {
        let view = FoodBannerView.loadXib()
        view.roundAll = true
        return view
    }()
            
    private lazy var domesticContainerView = UIView(frame: .zero)
    private lazy var domesticDeliveryVC = DomesticDeliveryVC()
    private weak var domesticBookingView: DomesticBookingView?
    
    private lazy var dataSource: [OptionDeliveryModel] =
        [OptionDeliveryModel(id: 0, option: Text.pakageSizeBig.localizedText, price: 0),
         OptionDeliveryModel(id: 0, option: Text.fastDelivery.localizedText, price: 0)]
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            UIApplication.setStatusBar(using: .darkContent)
        } else {
            UIApplication.setStatusBar(using: .default)
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    /// Class's private properties.
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        guard self.bookView?.showing == true else {
//            return
//        }
//
//        self.bookView?.dimiss(true)loadView
//    }
}

// MARK: View's event handlers
extension MainDeliveryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func addBooking(view: MainDeliveryBookingView) {
        bookView = view
        view >>> self.view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        view.dimiss(false)
    }
    
    func addDomesticBooking(view: DomesticBookingView) {
        domesticBookingView = view
        view >>> self.view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        view.dimiss(false)
    }
    
    
    func showConfirmView() {
        bookView?.show()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: Class's private methods
private extension MainDeliveryVC {
    func createHeaderView() {
        self.headerView = VatoLocationHeaderView.loadXib()
        self.headerView.titleLabel.text = Text.deliveryTitleAdressSender.localizedText
        self.headerContentView.backgroundColor = .white
        
        var edgeSafe = UIEdgeInsets.zero
        if #available(iOS 11, *) {
            edgeSafe = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        } else {
            edgeSafe = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        
        
        let h = headerView.frame.size.height
        
        headerContentView >>> view >>> { $0.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().priority(.high)
            $0.height.greaterThanOrEqualTo(h + edgeSafe.top)
            }
        }
        
        headerView >>> headerContentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalTo(edgeSafe.top)
                make.bottom.equalToSuperview()
            })
        }
    }
    
    func setDisplayNavigationBar() {
        if #available(iOS 13.0, *) {
            UIApplication.setStatusBar(using: .darkContent)
        } else {
            UIApplication.setStatusBar(using: .default)
        }

        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(nil, for: .default)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.shadowImage = UIImage()
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        self.createHeaderView()
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(headerContentView.snp.bottom).offset(10).priority(.high)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
            })
        }
        
        let v =  UIView(frame: .zero)
        v.backgroundColor = .white
        deliveryTypeView >>> v >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().priority(.high)
                make.left.right.bottom.equalToSuperview()
                })
        }
        let size = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)

        v.frame = CGRect(origin: .zero, size: size)
        
        tableView.tableHeaderView = v
        
        let section = Section() { (s) in
            s.tag = "Section"
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
        
        let button = UIButton(frame: .zero)
        button >>> view >>> {
            $0.setBackground(using: Color.orange, state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-20)
                make.height.equalTo(48)
            })
        }
        button.isEnabled = false
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.book()
        })).disposed(by: disposeBag)
        self.btnNext = button
        
        domesticDeliveryVC.listener = self
        domesticContainerView >>> self.view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(tableView.snp.top).offset(47)
            }
        }
        
        addChild(domesticDeliveryVC)
        
        domesticDeliveryVC.view >>> domesticContainerView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        domesticDeliveryVC.didMove(toParent: self)
        
        domesticContainerView.isHidden = true
        
        self.addDomesticBooking(view: DomesticBookingView.loadXib())
    }
    
    func setupRX() {
        BannerManager.instance.requestBanner(type: VatoServiceAction.delivery.rawValue).bind(onNext: weakify({ (list, wSelf) in
            wSelf.sourceBanner.onNext(list)
        })).disposed(by: disposeBag)
        
        sourceBanner.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (list, wSelf) in
            guard !list.isEmpty else {
                wSelf.tableView.tableFooterView = nil
                return
            }
            
            let v = UIView(frame: .zero)
            v.backgroundColor = .white
            
            wSelf.footerView >>> v >>> {
                $0.setupDisplay(item: list)
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(216)
                    make.bottom.equalTo(-16).priority(.high)
                })
                
                $0.callback = { [weak self] item in
                    if self?.bookView?.showing == true {
                        self?.bookView?.dimiss(true)
                        return
                    }
                    
                    guard let item = item as? BannerProtocol, let url = item.url else {
                        return
                    }
                    WebVC.loadWeb(on: self, url: url, title: nil)
                }
            }
            v.addSeperator(with: .zero, position: .top)
            v.addSeperator(with: .zero, position: .bottom)
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
            
            wSelf.tableView.tableFooterView = v
        })).disposed(by: disposeBag)
        
        self.headerView.backButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)

        self.listener?.ready.bind(onNext: weakify({ (r, wSelf) in
            wSelf.btnNext?.isEnabled = r
//            guard r else { return }
//            wSelf.btnNext?.sendActions(for: .touchUpInside)
        })).disposed(by: disposeBag)
        
        self.listener?.sender.bind(onNext: weakify({ (info, wSelf) in
            wSelf.senderView.setupDisplay(item: info)
            wSelf.headerView.setupDisplay(item: info.originalDestination)
            wSelf.tableView.layoutSubviews()
        })).disposed(by: disposeBag)
        
        self.listener?.receiver.bind(onNext: weakify({ (info, wSelf) in
            wSelf.updateDeliveryCell(item: info)
        })).disposed(by: disposeBag)
        
        self.listener?.ready.bind(onNext: { [weak self] (isReady) in
            self?.containerEstimateView.isHidden = !isReady
        }).disposed(by: disposeBag)
        
        self.listener?.routeTrip.bind(onNext: { [weak self](routeTrip) in
            self?.lblTime.text = self?.convertSecondToMinutes(value: routeTrip.duration.value)
            self?.lblDistance.text = self?.convertToKm(value: routeTrip.distance.value)
        }).disposed(by: disposeBag)
        
        let senderEvent = self.senderView.touchUp.map { _ in DeliveryDisplayType.sender }.debug("senderEvent")
        let receiverEvent = self.receiverView.touchUp.map { _ in DeliveryDisplayType.receiver }.debug("receiverEvent")
        
        Observable.merge([senderEvent, receiverEvent]).bind(onNext: weakify({ (type, wSelf) in
            wSelf.bookView?.dimiss(true)
            wSelf.listener?.inputInformation(type, serviceType: .URBAN_DELIVERY, item: nil)
        })).disposed(by: disposeBag)
        
        self.listener?.listVehicle.bind(onNext: { [weak self] listVehicle in
            guard let me = self else {  return }
            me.deliveryTypeView.source = listVehicle
            me.deliveryTypeView.collectionView.reloadData()

            if !listVehicle.isEmpty {
                me.deliveryTypeView.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }).disposed(by: disposeBag)
        
        self.headerView.btnSearchAddress?.rx.tap.bind(onNext: { [weak self] in
            guard let me = self else { return  }
            me.listener?.inputInformation(.sender, serviceType: .URBAN_DELIVERY, item: nil)
        }).disposed(by: disposeBag)
        
        self.headerView.mapButton.rx.tap.bind { [weak self] in
            guard let me = self else { return  }
//            me.listener?.moveToLocationPicker()
            me.listener?.moveToPinLocation()
        }.disposed(by: disposeBag)
        
        self.deliveryTypeView.deliveryType.bind {[weak self] (type) in
            guard let me = self else { return }
            
            switch type {
            case .DOMESTIC_DELIVERY:
                me.domesticContainerView.isHidden = false
            case .URBAN_DELIVERY:
                me.domesticContainerView.isHidden = true
            }
                        
        }.disposed(by: disposeBag)
        
        self.listener?.domesticReceivers.bind(onNext: { [weak self] d in
            guard let wSelf = self else { return }
            wSelf.domesticDeliveryVC.applyDelivery(d: d)
        }).disposed(by: disposeBag)
        
        if let domesticBookingView = self.domesticBookingView {
            domesticBookingView.scheduleButton.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.routeToChooseTime(model: nil)
            })).disposed(by: disposeBag)
            
            domesticBookingView.bookingButton.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToDeliverySuccess()
            })).disposed(by: disposeBag)
        }
    }
    
    func resetNavigation() {
        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = Text.delivery.localizedText
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        
        UIApplication.setStatusBar(using: .lightContent)
        
        self.navigationController?.navigationBar.tintColor = .white
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
        }.disposed(by: disposeBag)
    }
    
    private func convertToKm(value: Double) -> String {
        let km = value / 1000
        return "\(km.round(to: 1).cleanValue) km"
    }
    
    private func convertSecondToMinutes(value: Double) -> String {
        let (hr,  minf) = modf (value / 3600)
        let (min, _) = modf (60 * minf)
        if hr > 0 {
            return "\(hr.cleanValue) \(Text.hour.localizedText) \(min.cleanValue) \(Text.minute.localizedText)"
        }
        return "\(min.cleanValue) \(Text.minute.localizedText)"
    }
    
    private func updateDeliveryCell(item: DestinationDisplayProtocol) {
        guard let section = self.form.sectionBy(tag: "Section") else {
            return
        }
        if !section.isEmpty {
            section.remove(at: 0)
        }
        section <<< self.createDeliveryCell(item: item)
    }
    
    private func createDeliveryCell(item: DestinationDisplayProtocol) -> RowDetailGeneric<DeliveryInformationCell> {
        return RowDetailGeneric<DeliveryInformationCell>.init(Config.DeliveryCellIdentifier , { [weak self] (row) in
            row.onCellSelection({ [weak self] (cell, row) in
                guard let me = self else { return }
                if me.bookView?.showing == true {
                    me.bookView?.dimiss(true)
                    return
                }
                me.listener?.inputInformation(.receiver, serviceType: .URBAN_DELIVERY, item: nil)
            })
            row.cell.updateData(item: item)
            guard let me = self else { return }
            row.cell.rightIconButton.rx.tap.bind(onNext: { [weak self] in
                guard let me = self else { return }
                me.listener?.removeReceiverIfNeed(type: .receiver)
            }).disposed(by: me.disposeBag)
        })
    }
}


extension MainDeliveryVC: DomesticDeliveryVCProtocol {
    func routeToFillInfomation(item: DeliveryInputInformation?) {
        self.listener?.inputInformation(.receiver, serviceType: .DOMESTIC_DELIVERY, item: item)
    }
    
    
    func removeDeliveryItem(item: DeliveryInputInformation?) {
        self.listener?.removeDomesticItem(item: item)
    }
    
    
    func showBookingView() {
        domesticBookingView?.show()
    }
}


extension MainDeliveryVC {
    func routeToChooseTime(model: DateTime?) {
        let vc = UIStoryboard(name: "PickerTime", bundle: nil).instantiateViewController(withIdentifier: "PickerTimeViewController") as! PickerTimeViewController
        vc.listener = self
        vc.defaultModel = model
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen

        self.present(vc, animated: true, completion: nil)
    }
}


extension MainDeliveryVC: PickerTimeViewControllerListener {
    func selectTime(model: DateTime?) {
        
    }
}
