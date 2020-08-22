//  File name   : ShoppingMainVC.swift
//
//  Author      : khoi tran
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift

protocol ShoppingMainPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var sender: Observable<DestinationDisplayProtocol> { get }
    var receiver: Observable<DestinationDisplayProtocol> { get }
    var ready: Observable<Bool> { get }
    var routeTrip: Observable<RouteTrip> { get }
    
    func book()
    func inputInformation(_ type: DeliveryDisplayType, serviceType: DeliveryServiceType, item: DeliveryInputInformation?)
    func removeReceiverIfNeed(type: DeliveryDisplayType)
    func moveBack()
    func moveToPinLocation()
    func routeToLocationPicker()
}

final class ShoppingMainVC: FormViewController, ShoppingMainPresentable, ShoppingMainViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    
    
    private struct Config {
        static let DeliveryCellIdentifier = "DeliveryCellIdentifier"
        static let url = "https://vato.vn/huong-dan-su-dung-va-quy-dinh-su-dung-dich-vu-vato-market/"
    }
    
    /// Class's public properties.
    weak var listener: ShoppingMainPresentableListener?
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
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
    
    
}

// MARK: View's event handlers
extension ShoppingMainVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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

// MARK: Class's public methods
extension ShoppingMainVC {
}

// MARK: Class's private methods
private extension ShoppingMainVC {
    private func localize() {
        // todo: Localize view's here.
        if #available(iOS 13.0, *) {
            UIApplication.setStatusBar(using: .darkContent)
        } else {
            UIApplication.setStatusBar(using: .default)
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.createHeaderView()
        headerContentView.addSeperator()
        tableView >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(headerContentView.snp.bottom).priority(.high)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
            })
        }
        
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        
        let s1 = Text.vatoRec.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .regular))
        let s2 = "VATOPAY\n".attribute >>> .color(c: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .medium))
        let s3 = Text.keepContact.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .regular))
        let s4 = Text.findOut.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .regular))
        
        let s5 = Text.termOfUseService.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 12, weight: .regular))
        let att = s1 >>> s2 >>> s3 >>> s4 >>> s5
        
        let label = UILabel.create {
            $0.numberOfLines = 0
            $0.attributedText = att
        }
        
        
        label >>> v >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-10)
            }
        }
        
        let btPolicy: UIButton = UIButton(type: .system)
        btPolicy.backgroundColor = .clear
        
        btPolicy >>> v >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalTo(label)
                make.height.equalTo(50)
            }
        }
        
        btPolicy.rx.tap.bind { _ in
            WebVC.loadWeb(on: self, url: URL(string: Config.url), title: "")
        }.disposed(by: disposeBag)
        
        let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                   v.frame = CGRect(origin: .zero, size: s)
                   
        self.tableView.tableFooterView = v
        
        
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
        
        self.btnNext = button
    }
    
    private func setupRX() {
        
        
        self.headerView.backButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        self.headerView.btnSearchAddress?.rx.tap.bind(onNext: { [weak self] in
            guard let me = self else { return  }
            me.listener?.routeToLocationPicker()
        }).disposed(by: disposeBag)
        
        self.headerView.mapButton.rx.tap.bind { [weak self] in
            guard let me = self else { return  }
            me.listener?.moveToPinLocation()
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
        
        btnNext?.rx.tap.bind(onNext: weakify({ (wSelf) in
                   wSelf.listener?.book()
               })).disposed(by: disposeBag)
    }
}


extension ShoppingMainVC {
    
    func addBooking(view: MainDeliveryBookingView) {
        bookView = view
        view >>> self.view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        view.dimiss(false)
    }
    
    func createHeaderView() {
        self.headerView = VatoLocationHeaderView.loadXib()
        self.headerView.titleLabel.text = Text.deliveryTitleAdressReceiver.localizedText
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
    
}


extension ShoppingMainVC {
    private func updateDeliveryCell(item: DestinationDisplayProtocol) {
        guard let section = self.form.sectionBy(tag: "Section") else {
            return
        }
        if !section.isEmpty {
            section.remove(at: 0)
        }
        section <<< self.createDeliveryCell(item: item)
    }
    
    private func createDeliveryCell(item: DestinationDisplayProtocol) -> RowDetailGeneric<ShoppingDeliveryInformationCell> {
        return RowDetailGeneric<ShoppingDeliveryInformationCell>.init(Config.DeliveryCellIdentifier , { [weak self] (row) in
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
    
    func showConfirmView() {
        bookView?.show()
    }
}

extension ShoppingMainVC {
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
}
